{-# LANGUAGE ForeignFunctionInterface, ScopedTypeVariables #-}
module Gtagsjs (runParser) where

import Control.Exception

import Foreign

import Gtags
import qualified Gtags.JavaScript

import System.IO

import Prelude hiding (catch)

runParser :: Ptr ParserParam -> IO ()
runParser p = runGtags Gtags.JavaScript.parser p
              `catch` \(e :: SomeException) -> hPrint stderr (show e)
  
foreign export ccall "gtagsjs_parser"
  runParser :: Ptr ParserParam -> IO ()