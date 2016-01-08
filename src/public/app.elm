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
import ItemView


-- MODEL

type alias Model =
    { items : List Item
    , itemFilter :
        { display: String
        , sortBy: ( String, String )
        , category: String
        }
    }

initialModel : Model
initialModel =
  { items = [ ]
  , itemFilter =
      { display = "icons"
      , sortBy = ("price", "ascending")
      , category = "all"
      }
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
      ( { model | items = (Maybe.withDefault model.items maybeItemList) }
      , Effects.none
      )

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


-- VIEW

view address model =
    div
      [ appStyle, id "container" ]
      [ pageHeader
      , ItemView.view model.items
      , pageFooter
      ]

pageHeader : Html
pageHeader =
  div [ class "page-header" ]
    [ h1 [ ] [ text "Zmite" ]
    ]

pageFooter : Html
pageFooter =
  p [ class "page-footer" ] [ text "github.com/ezekeal"]

app =
  StartApp.start
    { init = (initialModel, getItems UpdateItems)
    , update = update
    , view = view
    , inputs = [ ]
    }

main =
  app.html

-- Style

appStyle =
  style
    [ ]
