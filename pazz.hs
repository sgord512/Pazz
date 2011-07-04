module Main
       where
import Database.HDBC
import Database.HDBC.Sqlite3
import qualified System.Console.CmdArgs.Explicit as Cmd

dbPath = "pazzdb.db"
dbInitializer = "pazzdb.sql"
dbTestInitializer = "pazzdbtest.sql"

main = do
     putStrLn "PAZZ: by Spencer Gordon. Press any key to quit."
     db <- connectSqlite3 dbPath
     dbInitFile <- readFile dbInitializer
     dbInitCmds <- prepare db dbInitFile
     executeRaw dbInitCmds
     putStrLn "Connection succesful."
     getLine

{-- Functions that handle all the querying and give me the appropriate data --}

--insertAlbum :: Album -> IO String
--insertArtist :: Artist -> IO String
--insertSong :: Song -> IO String

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
 