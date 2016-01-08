module Action where

import SmiteItems exposing (Item, ItemFilter)

type Action
  = NoOp
  | UpdateItems (Maybe (List Item))
  | FilterItems ItemFilter
  | SelectItem Int
