--Filename: pazz.hs
--Project: pazz, a command-line program for managing notes made about music using SQLite
--Author: Spencer Gordon
--Date: July 6th, 2011



module Main
       where
import Database.HDBC
import Database.HDBC.Sqlite3
import System.Environment

dbPath = "pazzdb.db"
dbInitializer = "pazzdb.sql"
dbTestInitializer = "pazzdbtest.sql"

usageError :: String -> IO a
usageError = ioError . userError

main = do
     putStrLn "PAZZ: by Spencer Gordon"
     db <- connectSqlite3 dbPath
     dbInitFile <- readFile dbInitializer
     dbInitCmds <- prepare db dbInitFile
     catch (handleSqlError $ executeRaw dbInitCmds) (\error -> putStrLn $ show error)
     putStrLn "Database loaded successfully. Ready for commands."
     args <- getArgs
     output <- catch (handleSqlError (processCmds db args)) (\error -> return $ show error) 
     putStrLn output

{-- Command-line processing --}

processCmds :: Connection -> [String] -> IO String
processCmds db (x:xs) | x == "add" = do insertSong db xs
                                        return "nay" 
                   | x == "list" = if null xs then do listAll
                                                      return "Listing all the songs"
                                              else usageError "List takes no arguments."
                   | otherwise = usageError "Command not recognized. For List of available commands, use \"--help\""
processCmds db [] = usageError "No command provided. For list of available commands, use \"--help\""

{-- Functions for inserting various types of things in the database. Designed to abstract away previous existence--} 

insertAlbum :: Connection -> [String] -> IO ()
insertAlbum db _ = do putStrLn "adding Album"
                      return ()
insertArtist :: Connection -> [String] -> IO ()
insertArtist db _ = do putStrLn "adding Artist"
                       return ()
insertSong :: Connection -> [String] -> IO ()
insertSong db (songName:artistName:albumName:[]) = do 
                                              artist_id <- artistId db artistName
                                              album_id <- albumId db albumName 
                                              createSong db songName album_id artist_id 
                                              return ()
insertSong db _ = usageError "incorrect number of arguments provided." 

createSong :: Connection -> Name -> Integer -> Integer -> IO Integer
createSong db song_name album_id artist_id = do
                                   songInsertingCmds <- prepare db sql
                                   songResult <- execute songInsertingCmds []
                                   return songResult
                                   where sql = ("insert into songs (song_name, album_id, song_notes) values ('" ++ song_name) ++ ("', NULL); insert into artist_song_bridge (artist_id, song_id) values ((select song_id from songs where song_name='" ++ song_name) ++ ("'), " ++ show artist_id) ++ ");"

artistId :: Connection -> Name -> IO Integer
artistId db a = do
         cmds <- prepare db sql
         result <- fetchRow cmds
         case result of Nothing -> do
                                insertingCmds <- prepare db sql_insert
                                handleSqlError $ execute insertingCmds []
                                newResult <- fetchRow cmds
                                return $ maybe 0 (head . (map fromSql)) newResult
                        Just (x:xs) -> return $ fromSql x
         where sql = "select artist_id from artists where artist_name = '" ++ a ++ "';"
               sql_insert = "insert into artists (artist_name, artist_notes) values ('" ++ a ++ "', NULL);" 

albumId :: Connection ->Name -> IO Integer
albumId db a = return 8
{--albumId a = do
        cmds <- prepare db sql
        result <- fetchRow cmds
        case result of Nothing -> do
                               insertingCmds <- prepare db sql_insert
                               handleSqlError $ execute insertingCmds []
                               newResult <- fetchRow cmds
                               return $ fromSql (head newResult)
                       Just (x:xs) -> return $ fromSql x 
                            where sql = "select album_id from albums where album_name = '" ++ a ++ "';"
                                  sql_insert "insert into albums (album_name, album_notes) values ('" ++ a ++ "', NULL);" 
--}


listAll :: IO String
listAll = return "listing all"

{--Defined typeclasses, data, and types--}

type Note = String
type Name = String
type AlbumName = String 
type ArtistName = String
data Artist = Artist Name Note deriving (Show)
data Album = Album Name Note deriving (Show)
data Song = Song Name Note AlbumName [ArtistName] deriving (Show)

class Noteable a where
      note :: a -> Note
      name :: a -> Name

instance Noteable Artist where
         note (Artist name notes) = notes

instance Noteable Album where
         note (Album name notes) = notes

instance Noteable Song where
         note (Song name notes albumName artistNames) = notes 

--}