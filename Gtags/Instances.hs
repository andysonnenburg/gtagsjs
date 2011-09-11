module Gtags.Instances () where

import Control.Monad.Reader

import Gtags.Class

instance MonadGtags m => MonadGtags (ReaderT r m) where
  getSize = lift getSize
  getFlags = lift getFlags
  getFile = lift getFile
  getFileContents = lift getFileContents
  put tagType tag lineNumber line = lift $ put tagType tag lineNumber line
  isNotFunction = lift . isNotFunction
  getLangMap = lift getLangMap
  die = lift . die
  warning = lift . warning
  message = lift . message