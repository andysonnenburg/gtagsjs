module Main (main) where

import Data.Set (Set, member)
import qualified Data.Set as Set

import Distribution.PackageDescription hiding (Flag)
import Distribution.Simple
import Distribution.Simple.BuildPaths
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Program
import Distribution.Simple.Setup
import Distribution.Text
import qualified Distribution.Verbosity as Verbosity

import System.Directory (removeFile)
import System.IO.Error (try)
import System.Process (system)

import Text.PrettyPrint

main :: IO ()
main = defaultMainWithHooks simpleUserHooks'
  where
    simpleUserHooks' = simpleUserHooks
      { preConf = preConf'
      , confHook = confHook'
      , postConf = postConf'
      , postClean = postClean'
      }
    
    preConf' x configFlags =
      preConf simpleUserHooks x (updateConfigFlags configFlags)
    
    confHook' x configFlags =
      confHook simpleUserHooks x (updateConfigFlags configFlags)
    
    postConf' x configFlags desc y = do
      writeFile "config.h" configH
      let configFlags' = updateConfigFlags configFlags
      postConf simpleUserHooks x configFlags' desc y
      where
        configH =
          concat
          [ "#ifndef CONFIG_H\n"
          , "#define CONFIG_H\n"
          , "\n"
          , "#define GTAGSJS_ROOT " ++ gtagsjsRoot ++ "\n"
          , "\n"
          , "#endif"
          ]
        gtagsjsRoot =
          concat ["__stginit_", encoded, "_Gtagsjs"]
          where
            encoded = zEncode (render . disp . packageId $ desc)
    
    updateConfigFlags configFlags =
      configFlags { configSharedLib = Flag True }
    
    postClean' _ _ _ _ = do
      try . removeFile $ "config.h"
      return ()

zEncode :: String -> String
zEncode = concatMap encodeChar
  where
    encodeChar x =
      case x of
        'z' -> "zz"
        'Z' -> "ZZ"
        '(' -> "ZL"
        ')' -> "ZR"
        '[' -> "ZM"
        ']' -> "ZN"
        ':' -> "ZC"
        '&' -> "za"
        '|' -> "zb"
        '^' -> "zc"
        '$' -> "zd"
        '=' -> "ze"
        '>' -> "zg"
        '#' -> "zh"
        '.' -> "zi"
        '<' -> "zl"
        '-' -> "zm"
        '!' -> "zn"
        '+' -> "zp"
        '\'' -> "zq"
        '\\' -> "zr"
        '/' -> "za"
        '*' -> "zt"
        '_' -> "zu"
        '%' -> "zv"
        x | x `member` regularLetters -> [x]       
          | otherwise -> undefined
    regularLetters = Set.fromList (concat [ ['a'..'y']
                                          , ['A'..'Y']
                                          , ['0'..'9']
                                          ])
        