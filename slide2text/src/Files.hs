{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}

module Files where

import Data.ByteString.Lazy (ByteString)
import Data.ByteString.Lazy.Char8 qualified as BL
import Data.Char
import System.FilePath
import System.Process.Typed

data Command = Command
    { name :: String
    , args :: [String]
    }

command :: Command -> ProcessConfig () () ()
command (Command n a) = proc n a

getText :: FilePath -> IO (ByteString, FilePath)
getText f = do
    -- TODO: better error handling
    (exit, out, err) <- readProcess $ (command . makeCmd) f
    case exit of
        ExitSuccess -> pure (out, f)
        ExitFailure e -> putStrLn ("Failed with exit code:" <> show e <> show err) >> undefined

makeCmd :: FilePath -> Command
makeCmd f = Command "tesseract" ["-l", "eng", f, "-"]

-- TODO: use builder
entry :: ByteString -> FilePath -> ByteString
entry b f = BL.pack (p <> takeBaseName f <> p <> "\n") `BL.append` BL.filter isAscii b
  where
    p = replicate 10 '='
