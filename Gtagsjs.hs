{-# LANGUAGE ForeignFunctionInterface, ScopedTypeVariables #-}
module Gtagsjs (runParser) where

import Control.Exception

import Foreign

import Gtags
import qualified Gtags.JavaScript

import System.IO

import Prelude hiding (catch)

runParser :: Ptr ParserParam -> IO ()
runParser param = runGtags Gtags.JavaScript.parser param
                  `catch` \(err :: SomeException) -> hPrint stderr (show err)
  
foreign export ccall "gtagsjs_parser"
  runParser :: Ptr ParserParam -> IO ()