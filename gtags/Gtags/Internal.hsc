{-# LANGUAGE DeriveDataTypeable #-}
module Gtags.Internal
       ( TagType (..)
       , fromTagType
       , Tag
       , LineNumber
       , Line
       ) where

#include "parser.h"

import Data.Bits
import Data.Data

data TagType = Def | RefSym deriving (Eq, Typeable, Data)
data Flag = Debug | Verbose | Warning | EndBlock | BeginBlock
newtype Flags = Flags { unFlags :: Int }
type Tag = String
type LineNumber = Int
type Line = String

fromTagType :: TagType -> Int
fromTagType x =
  case x of
    Def -> #{const PARSER_DEF}
    RefSym -> #{const PARSER_REF_SYM}

fromFlag :: Flag -> Int
fromFlag x =
  case x of
    Debug -> #{const PARSER_DEBUG}
    Verbose -> #{const PARSER_VERBOSE}
    Warning -> #{const PARSER_WARNING}
    EndBlock -> #{const PARSER_END_BLOCK}
    BeginBlock -> #{const PARSER_BEGIN_BLOCK}

toFlags :: Int -> Flags
toFlags = Flags

empty :: Flags
empty = Flags 0

null :: Flags -> Bool
null = (== 0) . unFlags

insert :: Flag -> Flags -> Flags
insert x = Flags . (fromFlag x .|.) . unFlags

member :: Flag -> Flags -> Bool
member x = (/= 0) . (fromFlag x .&.) . unFlags