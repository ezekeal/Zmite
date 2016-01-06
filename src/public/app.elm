module App where

import Graphics.Element exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task exposing (Task)
import StartApp as StartApp

import SmiteApi exposing (getItems)
import SmiteItems exposing (Item)


-- MODEL

type alias Model =
    { items : List Item
    }

initialModel : Model
initialModel =
  { items = [ ]
  }


-- UPDATE

type Action
  = NoOp
  | UpdateItems (Maybe (List Item))

update action model =
  case action of
    NoOp ->
      ( model, Effects.none )

    UpdateItems maybeItemList ->
      ( Model (Maybe.withDefault model.items maybeItemList)
      , Effects.none
      )

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


-- VIEW

view address model =
    div
      [ id "container" ]
      [ pageHeader
      , itemView model.items
      , pageFooter
      ]

pageHeader : Html
pageHeader =
  h1 [ ] [ text "Zmite" ]

pageFooter : Html
pageFooter =
  p [ ] [ text "github.com/ezekeal"]

itemView items =
  let
    itemIcons = List.map itemIcon items
  in
    ul [ class "items" ] itemIcons

itemIcon item =
  li [ ]
    [ img [ src item.itemIconUrl ] [ ] ]

app =
  StartApp.start
    { init = (initialModel, getItems UpdateItems)
    , update = update
    , view = view
    , inputs = [ ]
    }

main =
  app.html
