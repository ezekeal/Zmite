module Api where

import Effects
import Task exposing (Task)
import Http exposing (post, string, Error)

apiUrl =
  "http://localhost:5000/api/"


request decoder body action =
  Http.fromJson decoder
    (Http.send Http.defaultSettings
      { verb = "POST"
      , headers = [("Content-Type", "application/json")]
      , url = apiUrl
      , body = Http.string body
      })
      |> Task.toMaybe
      |> Task.map action
      |> Effects.task
