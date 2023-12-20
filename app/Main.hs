{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.ByteString.Lazy.Char8 qualified as BL
import Data.Text.Lazy qualified as TL
import Data.List
import Data.Traversable
import Files
import System.ProgressBar

myStyle :: Style s
myStyle =
    Style
    { styleOpen          = "["
    , styleClose         = "]"
    , styleDone          = '='
    , styleCurrent       = '>'
    , styleTodo          = '.'
    , stylePrefix        = percentage
    , stylePostfix       = exact
    , styleWidth         = ConstantWidth 40
    , styleEscapeOpen    = const TL.empty
    , styleEscapeClose   = const TL.empty
    , styleEscapeDone    = const TL.empty
    , styleEscapeCurrent = const TL.empty
    , styleEscapeTodo    = const TL.empty
    , styleEscapePrefix  = const TL.empty
    , styleEscapePostfix = const TL.empty
    , styleOnComplete    = WriteNewline
    }

main :: IO ()
main = do
    p <- cmdLineParser
    fs <- getFiles p
    pb <- newProgressBar myStyle 10 $ Progress 0 (length fs) ()
    bs <- forM fs $ \x -> incProgress pb 1 >> getText x
    mapM_ (putStrLn . BL.unpack . uncurry entry) $ sortOn snd bs
