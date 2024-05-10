module CLIParser where

import Options.Applicative hiding (command)

newtype Params = Params
    { dir :: [FilePath]
    }

data Output = Output FilePath | StdOut

cmdLineParser :: IO Params
cmdLineParser = execParser opts
  where
    opts =
        info
            (mkParams <**> helper)
            (fullDesc <> progDesc "extract text from folder of images and output to file")

mkParams :: Parser Params
mkParams =
    Params
        <$> some (strArgument (metavar "<FILES>" <> help "input images to OCR"))
