{-# LANGUAGE ForeignFunctionInterface, ScopedTypeVariables #-}
module Gtagsjs () where

import Control.Exception

import Foreign

import Gtags
import qualified Gtags.JavaScript
import Gtags.ParserParam

import System.IO

import Prelude hiding (catch)

parser :: Ptr ParserParam -> IO ()
parser ptr = do
  param <- peekParserParam ptr
  runGtags Gtags.JavaScript.parser param 
    `catch` \(err :: SomeException) ->
    hPrint stderr (show err)
  
foreign export ccall parser :: Ptr ParserParam -> IO ()