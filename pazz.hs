module Main
       where
import Database.HDBC
import Database.HDBC.Sqlite3
import System.Environment

dbPath = "pazzdb.db"
dbInitializer = "pazzdb.sql"
dbTestInitializer = "pazzdbtest.sql"

main = do
     putStrLn "PAZZ: by Spencer Gordon. Press any key to quit."
     db <- connectSqlite3 dbPath
     dbInitFile <- readFile dbInitializer
     dbInitCmds <- prepare db dbInitFile
     handleSqlError $ executeRaw dbInitCmds
     putStrLn "Database loaded successfully. Ready for commands."
     output <- processCmds getArgs
     putStrLn output
     getLine

{-- Functions that handle all the querying and give me the appropriate data --}

processCmds :: [String] -> IO String
processCmds (x:xs) | x == "add" = insertSong xs 
                   | x == "list" = if null xs then listAll
                                              else "list takes no arguments."
                   | otherwise = "Command not recognized. For List of available commands, use \"--help\""
processCmds [] = "No command provided. For list of available commands, use \"--help\""

--insertAlbum :: Album -> String
--insertArtist :: Artist -> String
--insertSong :: Song -> String

insertAlbum :: [String] -> IO ()
insertAlbum _ = "adding Album"
insertArtist :: [String] -> IO ()
insertArtist _ = "adding Artist"
insertSong :: [String] -> IO ()
insertSong (songName:artistName:albumName:[]) = do 
                                              artist_id <- artistId artistName
                                              album_id <- albumId albumName 
                                              createSong songName album_id artist_id 
                                              return


createSong :: Name -> Int -> Int -> IO Int
createSong song_name album_id artist_id = do
                                   songInsertingCmds <- prepare db sql
                                   songResult <- executeRaw songInsertingCmds
                                   return songResult
                                   where sql = "insert into songs (song_name, album_id, song_notes) values ('" ++ name ++ "', NULL); insert into artist_song_bridge (artist_id, song_id) values ((select song_id from songs where song_name='" ++ song_name "'), " ++ artist_id ++ ");"

artistId :: Name -> IO Int
artistId a = do
         cmds <- prepare db sql
         result <- fetchRow cmds
         case result of Nothing -> do
                                insertingCmds <- prepare db sql_insert
                                handleSqlError $ executeRaw insertingCmds
                                newResult <- fetchRow cmds
                                return $ fromSql (head newResult)
                        Just (x:xs) -> return $ fromSql x
         where sql = "select artist_id from artists where artist_name = '" ++ a ++ "';"
               sql_insert = "insert into artists (artist_name, artist_notes) values ('" ++ a ++ "', NULL);" 

albumId :: Name -> IO Int
albumId a = do
        cmds <- prepare db sql
        result <- fetchRow cmds
        case result of Nothing -> do
                               insertingCmds <- prepare db sql_insert
                               handleSqlError $ executeRaw insertingCmds
                               newResult <- fetchRow cmds
                               return $ fromSql (head newResult)
                       Just (x:xs) -> return $ fromSql x
        where sql = "select album_id from albums where album_name = '" ++ a ++ "';"
              sql_insert "insert into albums (album_name, album_notes) values ('" ++ a ++ "', NULL);" 

{-- Defined typeclasses, data, and types --}

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
 