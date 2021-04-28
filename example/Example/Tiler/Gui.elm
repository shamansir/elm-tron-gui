module Example.Tiler.Gui exposing (gui)

import Color
import Tron exposing (Tron)
import Tron.Builder.Unit as Tron
import Tron.Style.PanelShape exposing (..)
import Tron.Style.CellShape as CellShape exposing (..)
import Tron.Style.Theme as Theme



gui : Tron ()
gui =
    Tron.root
        [ ( "Color Scheme", Tron.none )
        , ( "Sizes", sizes |> Tron.face (icon "size") )
        , ( "Tile", tile |> Tron.face (icon "tile") )
        , ( "Randomness", randomness |> Tron.face (icon "settings") )
        , ( "Title", title |> Tron.face (icon "text") )
        , ( "Action on click", clickAction |> Tron.face (icon "cursor"))
        , ( "Shuffle color", Tron.button |> Tron.face (icon "shuffle"))
        , ( "Shuffle tiles", Tron.button |> Tron.face (icon "shuffle"))
        , ( "Change tiles", Tron.button |> Tron.face (icon "update" ))
        , ( "Export", Tron.button |> Tron.face (icon "export"))
        , ( "Save Scene", Tron.button |> Tron.face (icon "save" ))
        ]


icon : String -> Tron.Face
icon name =
    Tron.themedIconAt
        (\theme ->
            [ "assets"
            , "tiler"
            , case theme of
                Theme.Dark -> "light-stroke"
                Theme.Light -> "dark-stroke"
            , name ++ ".svg"
            ]
        )


sizes : Tron ()
sizes =
     Tron.nest
        [ ( "Cell", Tron.int { min = 0, max = 200, step = 1 } 0 )
        , ( "Shape", Tron.float { min = 0.01, max = 5, step = 0.1 } 0 )
        , ( "Board size", Tron.toggle False )
        ]
        |> Tron.shape (cols 3)


randomness : Tron ()
randomness =
     Tron.nest
        [ ( "Diversity", Tron.int { min = 0, max = 15, step = 1 } 0 )
        , ( "Scale", Tron.float { min = 0.1, max = 2, step = 0.1 } 0.1 )
        , ( "Ind. fill", Tron.toggle False )
        , ( "Colors", Tron.int { min = 1, max = 13, step = 1 } 1 )
        ]
        |> Tron.shape (cols 3)


tile : Tron ()
tile =
    Tron.nest
        [ ("Tileset", tileset)
        , ( "Fill", Tron.int { min = 0, max = 255, step = 1 } 178 )
        , ( "Opacity", Tron.int { min = 0, max = 255, step = 1 } 255 )
        , ( "Stroke", Tron.int { min = 0, max = 10, step = 1 } 1 )
        ]
        |> Tron.shape (cols 2)


tileset : Tron ()
tileset =
    Tron.strings
        [ "Geometric", "Fancy", "Lines"] "Foo"


title : Tron()
title =
    Tron.nest
        [ ( "Show", Tron.toggle False)
        , ( "Font size", Tron.int { min = 0, max = 72, step = 1 } 16 )
        , ( "Opacity", Tron.int { min = 0, max = 255, step = 1 } 255 )
        , ( "Position",
                Tron.xy
                    ( { min = -20, max = 20, step = 5 }
                    , { min = -20, max = 20, step = 5 }
                    )
                    (0, 0) )
        , ( "Color",  Tron.color <| Color.rgb255 255 194 0)
        ]
        |> Tron.shape (cols 3)


type ActionType
    = ChangeColor
    | ModifyTile
    | ChangeOpacity


actionTypeToString : ActionType -> String
actionTypeToString actionType_ =
    case actionType_ of
        ChangeColor -> "Change Color"
        ModifyTile -> "Modify Tile"
        ChangeOpacity -> "Change Opacity"



clickAction : Tron ()
clickAction =
    Tron.labels
        actionTypeToString
        [ ChangeColor, ModifyTile, ChangeOpacity ]
        ChangeColor
