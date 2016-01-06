module SmiteApi where

import Effects
import Json.Decode as Json exposing ((:=))
import Http exposing (post, string, Error)
import Task exposing (Task)

import Api
import SmiteItems


-- Getters

getItems action =
  Api.request SmiteItems.decode SmiteItems.params action
