module Gtags.Class
       ( module Gtags.Internal
       , MonadGtags (..)
       ) where

import Gtags.Internal

class Monad m => MonadGtags m where
  getSize :: m Int
  getFlags :: m Int
  getFile :: m FilePath
  getFileContents :: m String
  put :: TagType -> Tag -> LineNumber -> Line -> m ()
  isNotFunction :: String -> m Int
  getLangMap :: m String
  die :: String -> m ()
  warning :: String -> m ()
  message :: String -> m ()