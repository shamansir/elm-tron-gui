module Tron.Control.Switch exposing (..)

import Array exposing (Array)

import Axis exposing (Axis)
import Color

import Svg exposing (Svg)
import Svg.Attributes as SA exposing (..)

import Tron.Control as Core exposing (Control)

-- if the switch is being toggled now, we need to know its first value it had when user started dragging,
-- so it is the first `Maybe` in the pair
type alias Control a = Core.Control ( Array String ) ( Maybe Int, Int ) a

