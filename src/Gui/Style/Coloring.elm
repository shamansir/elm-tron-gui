module Gui.Style.Coloring exposing (..)


import Color
import Color exposing (Color)

import Gui.Style.Theme exposing (Theme(..))
import Gui.Focus exposing (Focused(..))
import Gui.Style.Placement exposing (Placement(..))
import Gui.Style.Selected exposing (Selected(..))


transparent = Color.rgba 0.0 0.0 0.0 0.0


{-|
-}
lines : Theme -> ( Placement, Focused, Selected ) -> Color
lines theme _ =
    case theme of
        Dark -> Color.white
        Light -> Color.rgb255 58 62 65 -- "#3a3e41"


{-|
-}
secondaryLines : Theme -> ( Placement, Focused, Selected ) -> Color
secondaryLines theme _ =
    case theme of
        Dark -> Color.rgba 1.0 1.0 1.0 0.15
        Light -> Color.rgb255 220 220 220 -- "#eeeeee"


{-|
-}
back : Theme -> ( Placement, Focused, Selected ) -> Color
back theme ( placement, focused, _ ) =
    case placement of
        OnAPlate -> transparent
        AtRoot ->
            case ( theme, focused ) of
                ( Dark, NotFocused ) -> Color.rgba 0.05 0.05 0.05 0.6
                ( Light, NotFocused ) -> Color.rgba 1.0 1.0 1.0 0.8
                ( Dark, FocusedBy _ ) -> Color.rgb 0.2 0.2 0.2
                ( Light, FocusedBy _ ) -> Color.rgb 1.0 1.0 1.0


{-|
-}
text : Theme -> ( Placement, Focused, Selected ) -> Color
text theme ( _, _, selected ) =
    case selected of
        Usual -> Color.rgb255 144 144 144
        Selected ->
            case theme of
                Dark -> Color.white
                Light -> Color.black



green = Color.rgb255 0 204 71 -- "#00cc47"


pink = Color.rgb255 237 49 162 -- "#ED31A2"


yellow = Color.rgb255 234 176 0 -- "#eab000"


aqua = Color.rgb255 35 205 232 -- "#23CDE8"


black = Color.rgb255 58 62 65 -- "#3a3e41"


type Tone
    = None
    | Green
    | Pink
    | Yellow
    | Aqua


none : Tone
none = None


back_ : ( Theme, Tone ) -> ( Placement, Focused, Selected ) -> Color
back_ ( theme, _ ) =
    back theme


lines_ : ( Theme, Tone ) -> ( Placement, Focused, Selected ) -> Color
lines_ ( theme, tone ) state =
    case tone of
        Green -> green
        Pink -> pink
        Yellow -> yellow
        Aqua -> aqua
        None -> lines theme state


secondaryLines_ : ( Theme, Tone ) -> ( Placement, Focused, Selected ) -> Color
secondaryLines_ ( theme, _ ) =
    secondaryLines theme


text_ : ( Theme, Tone ) -> ( Placement, Focused, Selected ) -> Color
text_ ( theme, _ ) =
    text theme


toString : Tone -> String
toString tone =
    case tone of
        Green -> "tone-1"
        Pink -> "tone-2"
        Yellow -> "tone-3"
        Aqua -> "tone-4"
        None -> "no-tone"


next : Tone -> Tone
next tone =
    case tone of
        Green -> Pink
        Pink -> Yellow
        Yellow -> Aqua
        Aqua -> Green
        None -> None
