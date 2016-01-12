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
import SmiteItems exposing (Item)
import ItemView


-- MODEL

type alias Model =
    { items : List Item
    , itemDisplay : String
    , itemSorting : String
    , itemSortType : String
    , itemFilters : List String
    , selectedItemId : Int
    }

initialModel : Model
initialModel =
  { items = [ ]
  , itemDisplay = "icons"
  , itemSorting = "descending"
  , itemSortType = "Price"
  , itemFilters = [ ]
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

    DisplayItems display ->
      ( { model |
          itemDisplay = display }
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

    SortItems sorting ->
      ( { model |
          itemSorting = sorting }
      , Effects.none
      )

    SetSortType sortType ->
      ( { model |
          itemSortType = sortType }
      , Effects.none
      )

    AddItemFilter filterName ->
      ( { model |
          itemFilters = filterName :: model.itemFilters }
      , Effects.none
      )

    RemoveItemFilter filterName ->
      ( { model |
          itemFilters = List.filter (\n -> n /= filterName) model.itemFilters }
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
