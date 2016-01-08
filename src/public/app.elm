module App where

import Graphics.Element exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task exposing (Task)
import StartApp as StartApp
import Action exposing (..)

import SmiteApi exposing (getItems)
import SmiteItems exposing (Item, ItemFilter)
import ItemView


-- MODEL

type alias Model =
    { items : List Item
    , itemFilter : ItemFilter
    , selectedItemId : Int
    }

initialModel : Model
initialModel =
  { items = [ ]
  , itemFilter =
      { display = "icons"
      , sorting = ("price", "ascending")
      , category = "all"
      }
  , selectedItemId = -1
  }


-- UPDATE


update action model =
  case action of
    NoOp ->
      ( model, Effects.none )

    UpdateItems maybeItemList ->
      ( { model |
          items = (Maybe.withDefault model.items maybeItemList) }
      , Effects.none
      )

    FilterItems itemFilter ->
      ( { model |
          itemFilter = itemFilter }
      , Effects.none
      )

    SelectItem itemId ->
      let
        newId =
          if model.selectedItemId == itemId then
            -1
          else
            itemId
      in
        ( { model |
            selectedItemId = newId }
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
      , ItemView.view address model
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
