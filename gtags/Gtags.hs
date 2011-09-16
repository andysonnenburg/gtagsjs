{-# LANGUAGE GeneralizedNewtypeDeriving, NamedFieldPuns #-}
module Gtags
       ( module Gtags.Class
       , Gtags
       , runGtags
       , ParserParam
       ) where

import Control.Applicative
import Control.Monad.Reader hiding (ask)
import qualified Control.Monad.Reader as Reader

import Gtags.Class
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

runGtags :: Gtags a -> ParserParam -> IO a
runGtags (Gtags m) = runReaderT m

ask :: Gtags R
ask = Gtags Reader.ask

instance MonadGtags Gtags where
  
  getSize = size <$> ask 
  
  getFlags = flags <$> ask
  
  getFile = file <$> ask
  
  getFileContents = getFile >>= Gtags . lift . readFile
  
  put tagType tag lineNumber line = do
    ParserParam { file, ParserParam.put = put' } <- ask
    Gtags . lift $ put' tagType tag lineNumber file line
  
  isNotFunction x = ask >>= Gtags . lift . flip ParserParam.isNotFunction x

  getLangMap = langMap <$> ask

  die x = ask >>= Gtags . lift . flip ParserParam.die x

  warning x = ask >>= Gtags . lift . flip ParserParam.warning x

  message x = ask >>= Gtags . lift . flip ParserParam.message x 