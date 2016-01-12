module SmiteItems where

import Json.Decode as Json exposing ((:=), succeed, list, string, int, bool, Decoder)
import Json.Decode.Extra exposing ((|:))


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


-- Enums

types =
  [ "Price"
  , "Health"
  , "Mana"
  , "Physical Protection"
  , "Magical Protection"
  , "Physical Power"
  , "Magical Power"
  , "Physical Penetration"
  , "Magical Penetration"
  , "Physical Lifesteal"
  , "Magical Lifesteal"
  , "HP5"
  , "MP5"
  , "Attack Speed"
  , "Critical Strike Chance"
  , "Cooldown Reduction"
  , "Crowd Control Reduction"
  , "Movement Speed"
  ]


-- JSON Decoders

decode : Decoder (List Item)
decode =
  list <|
    succeed Item
      |: ("ChildItemId" := int)
      |: ("DeviceName" := string)
      |: ("IconId" := int)
      |: ("ItemDescription" := decodeItemDescription)
      |: ("ItemId" := int)
      |: ("ItemTier" := int)
      |: ("Price" := int)
      |: ("RootItemId" := int)
      |: ("ShortDesc" := string)
      |: ("StartingItem" := bool)
      |: ("Type" := string)
      |: ("itemIcon_URL" := string)


decodeItemDescription : Decoder ItemDescription
decodeItemDescription =
  succeed ItemDescription
    |: ("Description" := string)
    |: ("Menuitems" := list decodeMenuItem)
    |: ("SecondaryDescription" := string)

decodeMenuItem : Decoder MenuItem
decodeMenuItem =
  succeed MenuItem
    |: ("Description" := string)
    |: ("Value" := string)
