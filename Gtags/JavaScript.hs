{-# LANGUAGE DeriveDataTypeable, StandaloneDeriving #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Gtags.JavaScript
       ( parser
       ) where

import BrownPLT.JavaScript

import Control.Monad.Reader

import Data.Array
import Data.Generics

import Gtags
import Gtags.Instances ()

import Text.ParserCombinators.Parsec.Pos

deriving instance Typeable SourcePos

instance Data SourcePos where
  toConstr _ = error "toConstr"
  gunfold _ _ = error "gunfold"
  dataTypeOf _ = mkNoRepType "Text.ParserCombinators.Parsec.Pos.SourcePos"

parser :: Gtags ()
parser = do
  file <- getFile
  contents <- getFileContents
  case parseScriptFromString file contents of
    Left err ->
      warning . show $ err
    Right script ->
      let lineArr = listArray (1, length contents) (lines contents)
      in runReaderT (q script) lineArr
  where
    q = everything (>>) $
        return () `mkQ`
        expr `extQ`
        stmt `extQ`
        catchClause `extQ`
        varDecl `extQ`
        prop `extQ`
        forInInit `extQ`
        lValue
    
    expr (VarRef _ x) =
      putId RefSym x
    expr (DotRef _ _ x) =
      putId RefSym x
    expr (FuncExpr _ name args _) = do
      maybe (return ()) (putId Def) name
      mapM_ (putId Def) args
    expr _ =
      return ()
    
    stmt (FunctionStmt _ name params _) = do
      putId Def name
      mapM_ (putId Def) params
    stmt _ =
      return ()
    
    catchClause (CatchClause _ x _) =
      putId Def x
    
    varDecl (VarDecl _ x _) =
      putId Def x
    
    prop (PropId _ x) =
      putId Def x
    prop (PropString p s) =
      put' Def p s
    prop (PropNum p i) =
      put' Def p (show i)
    
    forInInit (ForInVar x) =
      putId Def x
    forInInit f@(ForInNoVar x) = do
      warning (show f)
      putId Def x
    
    lValue (LVar p s) =
      put' RefSym p s
    lValue (LDot p _ s) =
      put' RefSym p s
    lValue _ =
      return ()
    
    putId tagType (Id p s) =
      put' tagType p s
    
    put' tagType p s = do
      lineArr <- ask
      put tagType s i (lineArr!i)
      where
        i = sourceLine p