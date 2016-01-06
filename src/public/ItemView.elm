module ItemView where

import Html exposing (..)
import Html.Attributes exposing (..)

view items =
  let
    tier3 = List.filter isTier3 items
    infoSheets itemList =
      List.map (infoSheet items) itemList
  in
    div [ class "items-view" ]
      [ itemGroup "Items" (infoSheets (List.filter isPassive tier3))
      , itemGroup "Actives" (infoSheets (List.filter isActive tier3))
      ]

icon item =
  li [ ]
    [ img [ src item.itemIconUrl ] [ ] ]

itemGroup title itemList =
  if List.length itemList > 0 then
    div [ class "item-group" ]
      [ h3 [ class "item-section-heading" ] [ text title ]
      , ul [ class "item-list" ] itemList
      ]
  else
    p [ ] [ text "Loading..." ]

infoSheet items item =
  div [ class "item-sheet" ]
    [ h4 [ class "title"] [ text item.deviceName ]
    , icon item
    , ul [ ] (stats item)
    , p [ ] [ text ("Price: " ++ toString (getFullPrice items item)) ]
    , p [ ] [ text item.itemDescription.description ]
    , p [ ] [ text item.itemDescription.secondaryDescription ]
    ]

stats item =
  let
    stat i =
      li [ ] [ text (i.description ++ " " ++ i.value)]
  in
    List.map stat item.itemDescription.menuItems

-- Data

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
