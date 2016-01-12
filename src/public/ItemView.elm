module ItemView where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, targetValue, on)
import Effects exposing (Effects)
import Task
import Action exposing (..)
import Maybe.Extra exposing (isNothing)
import SmiteItems as Item
import String exposing (startsWith, endsWith, dropLeft, toInt)
import Char exposing (isDigit)
import Graphics.Element exposing (show)

view address model =
  let
    sortItems items =
      getSorted items model.itemSorting model.itemSortType
    viewType =
      case model.itemDisplay of
        "info" ->
          infoView model.items
        _ ->
          iconView address model.items model.selectedItemId
  in
    div [ class "items-view" ]
      [ itemSelector address model
      , viewType (sortItems model.items)
      ]

iconView address items selectedItemId itemList =
  let
    iconList =
      List.map (clickableIcon address) itemList
    selectedItems =
      List.filter (hasId selectedItemId) items
  in
    div [ class "icon-view"]
      [ div [ ] [ itemGroup iconList ]
      , div [ class "item-sheet-gutter" ]
        [ div [ ] (List.map (infoSheet items) selectedItems)
        ]
      ]

infoView items itemList =
  List.map (infoSheet items) itemList
  |> itemGroup

icon item =
  div [ ] [ img [ src item.itemIconUrl ] [ ] ]
clickableIcon address item =
  li [ ]
    [ img
      [ src item.itemIconUrl
      , onClick address (SelectItem item.itemId)
      ] [ ]
    ]

itemGroup itemList =
  if List.length itemList > 0 then
    div [ class "item-group" ]
      [ ul [ class "item-list" ] itemList ]
  else
    p [ ] [ text "Loading..." ]

infoSheet items item =
  div [ class "item-sheet" ]
    [ h4 [ class "title"] [ text item.deviceName ]
    , p [ class "short-description" ] [ text item.shortDesc ]
    , icon item
    , ul [ class "stats" ] (stats item)
    , p [ class "price" ] [ text ("Price: " ++ toString (getFullPrice items item)) ]
    , p [ class "description" ] [ text item.itemDescription.description ]
    , p [ class "description" ] [ text item.itemDescription.secondaryDescription ]
    ]

stats item =
  let
    stat i =
      li [ ] [ text (i.description ++ " " ++ i.value)]
  in
    List.map stat item.itemDescription.menuItems


itemSelector address model =
  div [ class "filter"]
    [ span [ ] [ text "Display:" ]
    , span
        [ class (isSelected model.itemDisplay "icons")
        , onClick address (DisplayItems "icons")
        ]
        [ text "icons" ]
    , span
        [ class (isSelected model.itemDisplay "info")
        , onClick address (DisplayItems "info")
        ]
        [ text "info" ]
    , span [ ] [ text "Sort:" ]
    , select [ onChange address SetSortType ]
        (listToOptions Item.types)
    , div [ class "sort-arrows" ]
      [ i
          [ class ((isSelected model.itemSorting "descending") ++ " fa fa-caret-down")
          , onClick address (SortItems "descending")
          ] [ ]
      , i
        [ class ((isSelected model.itemSorting "ascending") ++ " fa fa-caret-up")
        , onClick address (SortItems "ascending")
        ] [ ]
      ]
    ]


-- Utils

getSorted items direction itemType =
  let
    filtered =
      if itemType == "Price" then
        items
      else
        hasStat items itemType
    sorted =
      List.sortBy (getStat items itemType) filtered
  in
    if direction == "ascending" then
      sorted
    else
      List.reverse sorted

getStat items stat item =
  let
    attrs =
      item.itemDescription.menuItems
    getVal attr =
      if attr.description == stat then
        statToInt attr.value
      else
        0
  in
    if stat == "Price" then
      getFullPrice items item
    else
      List.sum (List.map getVal attrs)

statToInt str =
  str
  |> String.filter (\c -> isDigit c || c == '-' )
  |> toInt
  |> Result.withDefault 0

hasStat items stat =
  List.filter (\item -> (getStat items stat item) > 0 ) items


listToOptions list =
  let textToOpt optText =
    option [ ] [ text optText ]
  in
    List.map textToOpt list

onChange : Signal.Address a -> (String -> a) -> Attribute
onChange address msg =
    on "change" targetValue (\str -> Signal.message address (msg str))

isSelected field filterName =
  if field == filterName then
    "selector selected"
  else
    "selector"

getFullPrice items item =
  let
    getRelated a =
      item.childItemId == a.itemId || item.rootItemId == a.itemId
    sumPrices prices =
      if item.itemId == item.rootItemId then
        item.price
      else
        item.price + List.sum prices
  in
    List.filter getRelated items
      |> List.map (\i -> i.price)
      |> sumPrices


-- Filters

isTier3 item =
  item.itemTier == 3

isActive item =
  item.itemType == "Active"

isPassive item =
  item.itemType == "Item"

hasId itemId item =
  item.itemId == itemId
