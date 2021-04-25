module Example.Default.Gui exposing (..)


import Color exposing (Color)

import Tron exposing (Tron)
import Tron.Builder as Gui
import Tron.Property  exposing (Property)
import Tron.Property as Property
import Tron.Style.PanelShape exposing (..)
import Tron.Style.CellShape exposing (..)
import Tron.Style.Theme as Theme


import Example.Default.Model exposing (..)
import Example.Default.Msg exposing (..)


for : Model -> Tron Msg
for model =
    Gui.root
        [ ( "ghost", Gui.none )
        , ( "int",
                Gui.int
                    { min = -20, max = 20, step = 5 }
                    model.int
                    ChangeInt )
        , ( "float",
                Gui.float
                    { min = -10.5, max = 10.5, step = 0.5 }
                    model.float
                    ChangeFloat )
        , ( "xy",
                Gui.xy
                    ( { min = -20, max = 20, step = 5 }
                    , { min = -20, max = 20, step = 5 }
                    )
                    model.xy
                    ChangeXY )
        , ( "text",
                Gui.text
                    model.string
                    ChangeString )
        , ( "color",
                Gui.color
                    model.color
                    ChangeColor )
        , ( "choice",
                Gui.choiceByCompare
                    ( cols 1 )
                    single
                    (choices
                        |> Gui.buttons
                        |> Gui.addLabels choiceToLabel
                    )
                    model.choice
                    compareChoices
                    Choose )
        , ( "nest",
                nestedButtons model.buttonPressed
                -- allControlsNest model
          )
        , ( "button",
                Gui.buttonWith
                    exportIcon
                    (always NoOp)
          )
        , ( "toggle",
                Gui.toggle
                    model.toggle
                    Switch
          )
        ]


nestedButtons : Choice -> Property Msg
nestedButtons curChoice =
    Gui.nest
        ( cols 2 )
        single
        [ ( "a", Gui.button <| always <| Pressed A )
        , ( "b", Gui.button <| always <| Pressed B )
        , ( "c", Gui.button <| always <| Pressed C )
        , ( "d", Gui.button <| always <| Pressed D )
        , ( "color", colorNest )
        ]


colorNest : Property Msg
colorNest =
    let
        colorCompKnob msg =
            Gui.float
                { min = 0, max = 255, step = 1 }
                0
                msg
    in
        Gui.nest
            ( cols 1 )
            single
            [ ( "red", colorCompKnob ChangeRed )
            , ( "green", colorCompKnob ChangeGreen )
            , ( "blue", colorCompKnob ChangeBlue )
            ]


allControlsNest : Model -> Property Msg
allControlsNest model =
    let
        colorCompKnob msg =
            Gui.float
                { min = 0, max = 255, step = 1 }
                0
                msg
    in
        Gui.nest
            ( rows 4 )
            single
            [ ( "ghost", Gui.none )
            , ( "int",
                    Gui.int
                        { min = -20, max = 20, step = 5 }
                        model.int
                        ChangeInt )
            , ( "float",
                    Gui.float
                        { min = -10.5, max = 10.5, step = 0.5 }
                        model.float
                        ChangeFloat )
            , ( "xy",
                    Gui.xy
                        ( { min = -20, max = 20, step = 5 }
                        , { min = -20, max = 20, step = 5 }
                        )
                        model.xy
                        ChangeXY )
            , ( "text",
                    Gui.text
                        model.string
                        ChangeString )
            , ( "color",
                    Gui.color
                        model.color
                        ChangeColor )
            , ( "choice",
                    Gui.choiceByCompare
                        ( cols 1 )
                        single
                        (choices
                            |> Gui.buttons
                            |> Gui.addLabels choiceToLabel
                        )
                        model.choice
                        compareChoices
                        Choose )
            , ( "nest",
                    nestedButtons model.buttonPressed
            )
            , ( "button",
                    Gui.buttonWith exportIcon (always NoOp)
            )
            , ( "toggle",
                    Gui.toggle
                        model.toggle
                        Switch
            )
            , ( "sqbutton",
                    Gui.button (always NoOp)
            )
            ]


choiceToLabel : Choice -> Property.Label
choiceToLabel c =
    case c of
        A -> "The A"
        B -> "The B"
        C -> "The C"
        D -> "The D"


exportIcon : Gui.Icon
exportIcon =
    Gui.themedIconAt
        (\theme ->
            [ "assets", "export_" ++ Theme.toString theme ++ ".svg" ]
        )
