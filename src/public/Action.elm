module Action where

import SmiteItems exposing (Item)

type Action
  = NoOp
  | UpdateItems (Maybe (List Item))
  | DisplayItems String
  | SelectItem Int
  | SortItems String
  | SetSortType String
  | ToggleItemFilter String
