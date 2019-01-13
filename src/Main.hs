{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# OPTIONS_GHC -fno-warn-name-shadowing -fno-warn-unused-binds -fno-warn-unused-imports #-}
module Main
  ( main
  ) where

import           Control.Applicative
import qualified Data.ByteString.Char8  as B
import           Data.Monoid            ((<>))
import           Network.HTTP.Types.URI (parseQuery)
import qualified Network.Slack.Api      as Slack
import           Options.Applicative
import           Data.String (fromString)

data Options = Options
  { token    :: String
  , endpoint :: String
  , params   :: [(String, String)]
  } deriving (Show, Eq)

parseOptions :: Parser Options
parseOptions =
  Options <$>
  strOption (long "token" <> short 't' <> metavar "TOKEN" <> help "Auth token") <*>
  strArgument (metavar "ENDPOINT" <> help "endpoint, e.g. channels.list") <*>
  (parseParams <$>
   (strArgument
      (metavar "PARAMS" <> help "API request params in request query format")))

parseParams :: String -> [(String, String)]
parseParams xs =
  let xs' = parseQuery $ B.pack xs
  in [(B.unpack a, B.unpack b) | (a, Just b) <- xs']

main :: IO ()
main =
  let opts =
        info
          (helper <*> parseOptions)
          (fullDesc <> progDesc "Probe the Slack API" <>
           header "slack-generic-client")
  in do Options {..} <- execParser opts
        r <- Slack.request (fromString token) endpoint params
        print r
        putStrLn "Done"
