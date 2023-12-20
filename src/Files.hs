{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module Files where

import Data.ByteString.Lazy (ByteString)
import Data.ByteString.Lazy.Char8 qualified as BL
import Data.Char
import Lens.Micro.Platform
import Options.Applicative
import System.Directory
import System.FilePath
import System.Process.Typed
import Text.RawString.QQ

newtype Command = Command {runCommand :: String}

data Params = Params
    { _dir :: FilePath
    , _output :: Output
    }

data Output = Output FilePath | StdOut

makeLenses ''Params

getFiles :: Params -> IO [FilePath]
getFiles p = do
    absP <- makeAbsolute $ p ^. dir
    fmap (absP </>) <$> listDirectory absP

cmdLineParser :: IO Params
cmdLineParser = execParser opts
  where
    opts =
        info
            (mkParams <**> helper)
            (fullDesc <> progDesc "extract text from folder of images and output to file")

fileOutput :: Parser Output
fileOutput =
    Output
        <$> strOption
            (long "output" <> short 'o' <> metavar "<OUTPUT>" <> help "output to file")

stdOutput :: Parser Output
stdOutput = flag' StdOut (short 's' <> long "stdout" <> help "output to stdout")

mkParams :: Parser Params
mkParams =
    Params
        <$> strArgument (metavar "<DIR>" <> help "input directory with images to OCR")
        <*> (fileOutput <|> stdOutput)

getText :: FilePath -> IO (ByteString, FilePath)
getText f = do
    -- TODO: check exit code
    (exit, out, _) <- readProcess $ shell $ (runCommand . makeCmd) f
    case exit of
        ExitSuccess -> pure (out, f)
        ExitFailure _ -> undefined

makeCmd :: FilePath -> Command
makeCmd f = Command $ "tesseract -l eng " ++ [r|'|] ++ f ++ [r|'|] ++ " -"

-- TODO: use builder
entry :: ByteString -> FilePath -> ByteString
entry b f = BL.filter isAscii b `BL.append` BL.pack (p ++ f ++ p ++ "\n")
  where
    p = replicate 10 '='
