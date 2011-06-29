module Main
       where

main = do
     putStrLn "PAZZ: by Spencer Gordon. Press any key to quit."
     contents <- readFile "pazz-data.txt"
     putStrLn contents
     getLine


type Note = String
type Name = String
data Artist = Artist Name Note [Album] deriving (Show)
data Album = Album Name Note [Song] deriving (Show)
data Song = Song Name Note deriving (Show)

class Noteable a where
      note :: a -> Note
      name :: a -> Name

instance Noteable Artist where
         note (Artist name notes albums) = notes

instance Noteable Album where
         note (Album name notes songs) = notes

instance Noteable Song where
         note (Song name notes) = notes 
 