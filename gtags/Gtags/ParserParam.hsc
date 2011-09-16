{-# LANGUAGE EmptyDataDecls, ForeignFunctionInterface, RecordWildCards #-}
module Gtags.ParserParam
       ( ParserParam (..)
       , peekParserParam
       ) where

#include "parser.h"

import Control.Monad

import Foreign
import Foreign.C.String

import Gtags.Internal

data ParserParam = ParserParam
                   { size :: Int
                   , flags :: Int
                   , file :: FilePath
                   , put :: Put
                   , isNotFunction :: IsNotFunction
                   , langMap :: String
                   , die :: Log
                   , warning :: Log
                   , message :: Log
                   }

type Put = TagType -> Tag -> LineNumber -> FilePath -> Line -> IO ()
type Arg = Ptr Void
data Void
type IsNotFunction = String -> IO Int
type Log = String -> IO ()

type Put' = Int -> CString -> Int -> CString -> CString -> Arg -> IO ()
type IsNotFunction' = CString -> IO Int
type Log' = CString -> IO ()

peekParserParam :: Ptr ParserParam -> IO ParserParam
peekParserParam ptr = do
  size <- peekSize ptr
  flags <- peekFlags ptr
  file <- peekFile ptr
  put <- peekPut ptr
  isNotFunction <- peekIsNotFunction ptr
  langMap <- peekLangMap ptr
  die <- peekDie ptr
  warning <- peekWarning ptr
  message <- peekMessage ptr
  return ParserParam {..}

peekSize :: Ptr ParserParam -> IO Int
peekSize = #{peek struct parser_param, size}

peekFlags :: Ptr ParserParam -> IO Int
peekFlags = #{peek struct parser_param, flags}

peekFile :: Ptr ParserParam -> IO FilePath
peekFile = #{peek struct parser_param, file} >=>
           peekCAString

peekPut :: Ptr ParserParam -> IO Put
peekPut ptr = do
  put' <- #{peek struct parser_param, put} ptr
  arg <- peekArg ptr
  return $ mkPut put' arg
  where
    peekArg = #{peek struct parser_param, arg}

peekIsNotFunction :: Ptr ParserParam -> IO IsNotFunction
peekIsNotFunction = fmap mkIsNotFunction . peekIsNotFunction'
  where
    peekIsNotFunction' = #{peek struct parser_param, isnotfunction}

peekLangMap :: Ptr ParserParam -> IO String
peekLangMap = #{peek struct parser_param, langmap} >=>
              peekCAString

peekDie :: Ptr ParserParam -> IO Log
peekDie = fmap (flip withCString . log') .
          #{peek struct parser_param, die}

peekWarning :: Ptr ParserParam -> IO Log
peekWarning = fmap (flip withCString . log') .
              #{peek struct parser_param, warning}

peekMessage :: Ptr ParserParam -> IO Log
peekMessage = fmap (flip withCString . log') .
              #{peek struct parser_param, message}

mkPut :: FunPtr Put' -> Arg -> Put
mkPut f arg tagType tag lineNumber file line =
  withCString tag $ \tag' ->
    withCString file $ \file' ->
      withCString line $ \line' ->
        (mkPut' f) (fromTagType tagType) tag' lineNumber file' line' arg

mkIsNotFunction :: FunPtr IsNotFunction' -> IsNotFunction
mkIsNotFunction = flip withCString . mkIsNotFunction'

foreign import ccall "dynamic"
  mkPut' :: FunPtr Put' -> Put'

foreign import ccall "dynamic"
  mkIsNotFunction' :: FunPtr IsNotFunction' -> IsNotFunction'

foreign import ccall unsafe "gtags_log"
  log' :: FunPtr Log' -> CString -> IO ()

