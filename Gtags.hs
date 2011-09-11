{-# LANGUAGE GeneralizedNewtypeDeriving, NamedFieldPuns #-}
module Gtags
       ( Gtags
       , runGtags
       , getSize
       , getFlags
       , getFile
       , getFileContents
       , put
       , isNotFunction
       , getLangMap
       , die
       , warning
       , message
       , ParserParam
       , module Gtags.Internal
       ) where

import Control.Applicative
import Control.Monad.Reader hiding (ask)
import qualified Control.Monad.Reader as Reader

import Foreign

import Gtags.Internal
import Gtags.ParserParam hiding (put, isNotFunction, die, warning, message)
import qualified Gtags.ParserParam as ParserParam

newtype Gtags a = Gtags
                  { unGtags :: ReaderT R IO a
                  } deriving ( Functor
                             , Applicative
                             )

instance Monad Gtags where
  return = Gtags . return
  Gtags m >>= k = Gtags (m >>= unGtags . k)
  fail = (>>) <$> die <*> Reader.fail

type R = ParserParam

runGtags :: Gtags a -> Ptr ParserParam -> IO a
runGtags (Gtags m) p = do
  r <- peekParserParam p
  runReaderT m r

ask :: Gtags R
ask = Gtags Reader.ask

getSize :: Gtags Int
getSize = size <$> ask 

getFlags :: Gtags Int
getFlags = flags <$> ask

getFile :: Gtags FilePath
getFile = file <$> ask

getFileContents :: Gtags String
getFileContents = getFile >>= Gtags . lift . readFile

put :: TagType -> Tag -> LineNumber -> Line -> Gtags ()
put type' tag lineNumber line = do
  ParserParam { file, ParserParam.put = f, arg } <- ask
  Gtags . lift $ f type' tag lineNumber file line arg

isNotFunction :: String -> Gtags Int
isNotFunction x = ask >>= Gtags . lift . flip ParserParam.isNotFunction x

getLangMap :: Gtags String
getLangMap = langMap <$> ask

die :: String -> Gtags ()
die x = ask >>= Gtags . lift . flip ParserParam.die x

warning :: String -> Gtags ()
warning x = ask >>= Gtags . lift . flip ParserParam.warning x

message :: String -> Gtags ()
message x = ask >>= Gtags . lift . flip ParserParam.message x 