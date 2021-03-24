module Tron.Control.Button exposing (..)


import Color exposing (Color)
import Tron.Style.Theme exposing (Theme)

import Tron.Control as Core exposing (Control)


type Url = Url String


type Icon = Icon (Theme -> Url)


type Face
    = Default
    | WithIcon Icon
    | WithColor Color


type alias Control msg = Core.Control Face () msg


icon : Url -> Icon
icon = Icon << always


themedIcon : (Theme -> Url) -> Icon
themedIcon = Icon


makeUrl : String -> Url
makeUrl = Url


urlToString : Url -> String
urlToString (Url str) = str