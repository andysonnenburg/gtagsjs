module Main (main) where

import Distribution.PackageDescription
import Distribution.Simple
import Distribution.Text

import Text.PrettyPrint

main :: IO ()
main = defaultMainWithHooks simpleUserHooks'
  where
    simpleUserHooks' = simpleUserHooks
      { postConf = postConf'
      }
    
    postConf' _ _ packageDescription _ =
      writeFile "config.h" configH
      where
        configH =
          "#ifndef CONFIG_H\n" ++
          "#define CONFIG_H\n" ++
          "\n" ++
          "#define GTAGSJS_ROOT " ++ gtagsjsRoot ++ "\n" ++
          "\n" ++
          "#endif"
        gtagsjsRoot =
          "__stginit_" ++
          zEncode (render . disp . packageId $ packageDescription) ++
          "_Gtagsjs"

zEncode :: String -> String
zEncode = concatMap encodeChar
  where
    encodeChar x =
      case x of
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
        x -> [x]