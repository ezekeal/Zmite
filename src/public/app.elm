module App where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)

import String exposing (toUpper, repeat, trimRight)

import StartApp.Simple as StartApp

main =
  text "Hello, World!"
