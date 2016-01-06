module SmiteItems where

import Json.Decode as Json exposing ((:=))


-- Params

params =
  """{ "method": "getitems", "params": ["1"] }"""

-- Types

type alias Item = {
    childItemId       : Int,
    deviceName        : String,
    iconId            : Int,
    itemDescription   : ItemDescription,
    itemId            : Int,
    itemTier          : Int,
    price             : Int,
    rootItemId        : Int,
    shortDesc         : String,
    startingItem      : Bool,
    itemType          : String,
    itemIconUrl       : String
}

type alias ItemDescription = {
  description           : String,
  menuItems             : List MenuItem,
  secondaryDescription  : String
}

type alias MenuItem = {
  description : String,
  value       : String
}


-- JSON Decoders

decode : Json.Decoder (List Item)
decode =
  Json.list <|
    Json.object1 Item ("ChildItemId" := Json.int)
      `apply` ("DeviceName" := Json.string)
      `apply` ("IconId" := Json.int)
      `apply` ("ItemDescription" := decodeItemDescription)
      `apply` ("ItemId" := Json.int)
      `apply` ("ItemTier" := Json.int)
      `apply` ("Price" := Json.int)
      `apply` ("RootItemId" := Json.int)
      `apply` ("ShortDesc" := Json.string)
      `apply` ("StartingItem" := Json.bool)
      `apply` ("Type" := Json.string)
      `apply` ("itemIcon_URL" := Json.string)


decodeItemDescription : Json.Decoder ItemDescription
decodeItemDescription =
  Json.object1 ItemDescription ("Description" := Json.string)
    `apply` ("Menuitems" := Json.list decodeMenuItem)
    `apply` ("SecondaryDescription" := Json.string)

decodeMenuItem : Json.Decoder MenuItem
decodeMenuItem =
  Json.object1 MenuItem ("Description" := Json.string)
    `apply` ("Value" := Json.string)

--Utilities

apply : Json.Decoder (a -> b) -> Json.Decoder a -> Json.Decoder b
apply func value =
    Json.object2 (<|) func value
