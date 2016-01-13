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
    filterItems =
      getFiltered model.items model.itemFilters
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
      , viewType (sortItems filterItems)
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
  let
    displayList =
      ["icons", "info"]
    filterList =
      ["Tier 1", "Tier 2", "Tier 3", "Active", "Passive"]
    displayClass =
      isSelected model.itemDisplay
    filterClass =
      isFiltered model.itemFilters
  in
    div [ class "filter"]
      [ filterSegment address "View:" DisplayItems displayClass displayList
      , filterSegment address "Show:" ToggleItemFilter filterClass filterList
      , div [ class "filter-segment" ]
        [ h5 [ class "filter-segment-title" ] [ text "Sort:" ]
        , div [ class "filter-select" ]
          [ div [ class "filter-select-container" ]
              [ select [ onChange address SetSortType ]
                  (listToOptions Item.types)
              ]
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
        ]
      ]

filterSegment address title action classFunc list =
  let clickable str =
    span
        [ class (classFunc str)
        , onClick address (action str)
        ]
        [ text str ]
  in
    div [ class "filter-segment" ]
    [ h5 [ class "filter-segment-title"] [ text title ]
    , div [ ] (List.map clickable list)
    ]


-- Utils
getFiltered items filterNames =
  if List.isEmpty filterNames then
    items
  else
    List.foldl (\name list -> (applyFilter list) name) items filterNames

applyFilter items filterName =
  let itemFilter =
    case filterName of
      "Tier 1" ->
        filterTier 1
      "Tier 2" ->
        filterTier 2
      "Tier 3" ->
        filterTier 3
      "Active" ->
        filterActive
      "Passive" ->
        filterPassive
      default ->
        noFilter
  in
    List.filter itemFilter items


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

isFiltered filterList filterName =
  if List.member filterName filterList then
    "selector"
  else
    "selector selected"

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

filterTier number item =
  item.itemTier /= number

filterActive item =
  item.itemType /= "Active"

filterPassive item =
  item.itemType /= "Item"

noFilter item =
  True

hasId itemId item =
  item.itemId == itemId
