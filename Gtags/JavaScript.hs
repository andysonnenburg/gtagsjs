module Gtags.JavaScript
       ( parser
       ) where

import BrownPLT.JavaScript

import Control.Applicative

import Gtags

import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr

parser :: Gtags ()
parser = do
  file <- getFile
  contents <- getFileContents
  case parseScriptFromString file contents of
    Left err -> die . show $ err
    Right (Script _ stmts) -> warning . show $ stmts