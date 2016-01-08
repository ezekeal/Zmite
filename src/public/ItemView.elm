module ItemView where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Effects exposing (Effects)
import Task
import Action exposing (..)
import Maybe.Extra exposing (isNothing)
import SmiteItems exposing (ItemFilter)

view address model =
  let
    tier3 =
      List.filter isTier3 model.items
    viewType =
      case model.itemFilter.display of
        "info" ->
          infoView model.items
        _ ->
          iconView address model.items model.selectedItemId
  in
    div [ class "items-view" ]
      [ itemSelector address model.itemFilter
      , viewType (List.filter isPassive tier3)
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

itemSelector : Signal.Address Action -> ItemFilter -> Html
itemSelector address itemFilter =
  div [ class "filter"]
    [ span [ ] [ text "Display:" ]
    , span
        [ class (isSelected itemFilter "icons")
        , onClick address (FilterItems { itemFilter | display = "icons"})
        ]
        [ text "icons" ]
    , span
        [ class (isSelected itemFilter "info")
        , onClick address (FilterItems { itemFilter | display = "info"})
        ]
        [ text "info" ]
    ]

-- Utils

isSelected itemFilter filterName =
  if itemFilter.display == filterName then
    "selector selected"
  else
    "selector"

getFullPrice items item =
  let
    getRelated a =
      item.childItemId == a.itemId || item.rootItemId == a.itemId
    sumPrices prices =
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
