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

peekParserParam :: Ptr ParserParam -> IO ParserParam
peekParserParam ptr = do
  size <- peekSize ptr
  flags <- peekFlags ptr
  file <- peekFile ptr
  put <- peekPut ptr
  arg <- peekArg ptr
  isNotFunction <- peekIsNotFunction ptr
  langMap <- peekLangMap ptr
  die <- peekDie ptr
  warning <- peekWarning ptr
  message <- peekMessage ptr
  return ParserParam {..}
  where
    peekSize = #{peek struct parser_param, size}
    
    peekFlags = #{peek struct parser_param, flags}
    
    peekFile = #{peek struct parser_param, file} >=>
               peekCAString
    
    peekPut = fmap mkPut . #{peek struct parser_param, put}
    
    peekArg = #{peek struct parser_param, arg}
    
    peekIsNotFunction = fmap mkIsNotFunction . peekIsNotFunction'
      where
        peekIsNotFunction' = #{peek struct parser_param, isnotfunction}
        
    peekLangMap = #{peek struct parser_param, langmap} >=>
                  peekCAString
                  
    peekDie = fmap (flip withCString . log') .
              #{peek struct parser_param, die}
              
    peekWarning = fmap (flip withCString . log') .
                  #{peek struct parser_param, warning}
                  
    peekMessage = fmap (flip withCString . log') .
                  #{peek struct parser_param, message}

mkPut :: FunPtr Put' -> Put
mkPut f tagType tag lineNumber file line args =
  withCString tag $ \tag' ->
    withCString file $ \file' ->
      withCString line $ \line' ->
        (mkPut' f) (fromTagType tagType) tag' lineNumber file' line' args

mkIsNotFunction :: FunPtr IsNotFunction' -> IsNotFunction
mkIsNotFunction = flip withCString . mkIsNotFunction'

foreign import ccall "dynamic"
  mkPut' :: FunPtr Put' -> Put'

foreign import ccall "dynamic"
  mkIsNotFunction' :: FunPtr IsNotFunction' -> IsNotFunction'

foreign import ccall unsafe "gtagsjs_log"
  log' :: FunPtr Log' -> CString -> IO ()

