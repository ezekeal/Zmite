module SmiteApi where

import Api
import SmiteItems

-- Getters

getItems action =
  Api.request SmiteItems.decode SmiteItems.params action
