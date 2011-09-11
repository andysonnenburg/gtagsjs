module Gtagsjs (runParser) where

import Foreign

import Gtags
import qualified Gtags.JavaScript

import System.IO

runParser :: Ptr ParserParam -> IO ()
runParser p = runGtags Gtags.JavaScript.parser p
              `catch` (hPrint stderr . show)
  
foreign export ccall "gtagsjs_parser" runParser :: Ptr ParserParam -> IO ()