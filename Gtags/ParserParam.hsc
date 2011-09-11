{-# LANGUAGE RecordWildCards #-}
module Gtags.ParserParam
       ( ParserParam (..)
       , peekParserParam
       ) where

#include "../parser.h"

import Control.Applicative

import Foreign
import Foreign.C.String

import Gtags.Internal

data ParserParam = ParserParam
                   { size :: Int
                   , flags :: Int
                   , file :: FilePath
                   , put :: Put
                   , arg :: Arg
                   , isNotFunction :: IsNotFunction
                   , langMap :: String
                   , die :: Log
                   , warning :: Log
                   , message :: Log
                   }

type Put = TagType -> Tag -> LineNumber -> FilePath -> Line -> Arg -> IO ()
type Arg = Ptr Void
data Void
type IsNotFunction = String -> IO Int
type Log = String -> IO ()

type Put' = Int -> CString -> Int -> CString -> CString -> Arg -> IO ()
type IsNotFunction' = CString -> IO Int
type Log' = CString -> IO ()

mkPut :: FunPtr Put' -> Put
mkPut = f . mkPut'
  where
    f g type' tag lineNumber file line args =
      withCString tag $ \ctag ->
        withCString file $ \cfile ->
          withCString line $ \cline ->
            g (fromTagType type') ctag lineNumber cfile cline args

mkLog :: FunPtr Log' -> Log
mkLog = flip withCString . mkLog'

mkIsNotFunction :: FunPtr IsNotFunction' -> IsNotFunction
mkIsNotFunction = flip withCString . mkIsNotFunction'

foreign import ccall "dynamic"
  mkPut' :: FunPtr Put' -> Put'

foreign import ccall "dynamic"
  mkIsNotFunction' :: FunPtr IsNotFunction' -> IsNotFunction'

foreign import ccall "dynamic"
  mkLog' :: FunPtr Log' -> Log'

peekParserParam :: Ptr ParserParam -> IO ParserParam
peekParserParam ptr = do
  size <- #{peek struct parser_param, size} ptr
  flags <- #{peek struct parser_param, flags} ptr
  file <- #{peek struct parser_param, file} ptr >>= peekCAString
  put <- mkPut <$> #{peek struct parser_param, put} ptr
  arg <- #{peek struct parser_param, arg} ptr
  isNotFunction <- mkIsNotFunction <$>
                  #{peek struct parser_param, isnotfunction} ptr
  langMap <- #{peek struct parser_param, langmap} ptr >>= peekCAString
  die <- mkLog <$> #{peek struct parser_param, die} ptr
  warning <- mkLog <$> #{peek struct parser_param, warning} ptr
  message <- mkLog <$> #{peek struct parser_param, message} ptr
  return ParserParam {..}