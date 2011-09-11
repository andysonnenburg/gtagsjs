module Gtags.Internal
       ( TagType (..)
       , fromTagType
       , Tag
       , LineNumber
       , Line
       ) where

#include "../parser.h"

data TagType = Def | RefSym
type Tag = String
type LineNumber = Int
type Line = String

fromTagType :: TagType -> Int
fromTagType x =
  case x of
    Def -> #{const PARSER_DEF}
    RefSym -> #{const PARSER_REF_SYM}
