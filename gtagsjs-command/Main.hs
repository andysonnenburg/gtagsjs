{-# LANGUAGE DeriveDataTypeable, RecordWildCards #-}
{-# OPTIONS_GHC -fno-cse #-}
module Main (main) where

import Data.Data

import Gtags (TagType (..), runGtags)
import qualified Gtags.JavaScript
import Gtags.ParserParam

import System.Console.CmdArgs
import System.Exit
import System.IO

import Text.Printf

data Gtagsjs = Gtagsjs
               { tagType :: TagType
               , files :: [String]
               } deriving (Typeable, Data)

gtagsjs :: Gtagsjs
gtagsjs = Gtagsjs { tagType = enum [Def, RefSym]
                  , files = def &= typFile &= args
                  }

main :: IO ()
main = do
  Gtagsjs {..} <- cmdArgs gtagsjs
  mapM_ (runGtags Gtags.JavaScript.parser . mkParserParam tagType) files

mkParserParam :: TagType -> FilePath -> ParserParam
mkParserParam tagType' file =
  ParserParam {..}
  where
    size = undefined
    flags = 0
    put tagType''
      | tagType'' == tagType' = put'
      | otherwise = \_ _ _ _ -> return ()
    put' tag lineNumber file' line =
      printf "%s\t%d\t%s\t%s\n" tag lineNumber file' line
    isNotFunction = const (return 0)
    langMap = undefined
    die x = do
      hPutStrLn stderr ("Error: " ++ x)
      exitFailure
    warning x =
      hPutStrLn stderr ("Warning: " ++ x)
    message _ =
      return ()
    
      