module Gui.Render.Property exposing (..)


import Color exposing (Color)

import Gui.Property exposing (..)

import Svg exposing (Svg)
import Svg.Attributes as SA
import Html.Attributes as HA
import Html.Events as HE

import Bounds exposing (Bounds)
import Gui.Path as Path exposing (Path)
import Gui.Msg exposing (Msg(..))
import Gui.Focus exposing (Focused(..))
import Gui.Control exposing (Control(..))
import Gui.Render.Util exposing (..)
import Gui.Render.Util as Svg exposing (none)
import Gui.Render.Util as Util exposing (arrow)
import Gui.Render.Style exposing (..)


gap = 6


borderRadius = 10


view : Theme -> Tone -> Path -> Bounds -> Focused -> ( Label, Property msg ) -> Svg Msg
view theme tone path bounds focus ( label, prop ) =
    Svg.g
        [ HE.onClick <| Click path
        , HA.style "pointer-events" "all"
        , HA.style "cursor" "pointer"
        , SA.class <| makeClass prop
        ]
        [
            Svg.rect
                [ SA.fill
                    <| Color.toCssString
                    <| if (Path.howDeep path == 1) then background theme else transparent
                , SA.x <| String.fromFloat (gap / 2)
                , SA.y <| String.fromFloat (gap / 2)
                , SA.rx <| String.fromFloat borderRadius
                , SA.ry <| String.fromFloat borderRadius
                , SA.width <| String.fromFloat (bounds.width - gap) ++ "px"
                , SA.height <| String.fromFloat (bounds.height - gap) ++ "px"
                ]
                []
        ,
            case prop of
                Number (Control { min, max } value _) ->
                    knob
                        theme
                        tone
                        { x = cellWidth / 2, y = (cellHeight / 2) }
                        <| (value - min) / (max - min)
                Coordinate (Control ( xAxis, yAxis ) ( xValue, yValue ) _) ->
                    coord
                        theme
                        tone
                        { x = cellWidth / 2, y = (cellHeight / 2) }
                        <|
                            ( (xValue - xAxis.min) / (xAxis.max - xAxis.min)
                            , (yValue - yAxis.min) / (yAxis.max - yAxis.min)
                            )
                Toggle (Control _ value _) ->
                    toggle theme tone value { x = cellWidth / 2, y = (cellHeight / 2) - 3 }
                Action (Control maybeIcon _ _) ->
                    button theme tone maybeIcon { x = cellWidth / 2, y = (cellHeight / 2) - 3 }
                Color (Control _ value _) ->
                    color theme tone value { x = cellWidth / 2, y = (cellHeight / 2) - 3 }
                Choice (Control _ ( expanded, _ ) _) ->
                    arrow theme tone expanded { x = cellWidth / 2, y = (cellHeight / 2) - 3 }
                Group (Control _ ( expanded, _ ) _) ->
                    arrow theme tone expanded { x = cellWidth / 2, y = (cellHeight / 2) - 3 }
                _ -> Svg.none
        , Svg.text_
            [ SA.textAnchor "middle"
            , SA.dominantBaseline "middle"
            , SA.x <| String.fromFloat (cellWidth / 2)
            , SA.y <| String.fromFloat (cellWidth / 5 * 4)
            , SA.fontSize "13px"
            , SA.fontFamily "\"IBM Plex Sans\", sans-serif"
            , SA.fill "rgb(144, 144, 144)"
            ]
            [ Svg.text label ]
        ]


knob : Theme -> Tone -> { x : Float, y : Float } -> Float -> Svg msg
knob theme tone center value =
    let
        toAngle v = (-120) + (v * 120 * 2)
        path stroke d =
            Svg.path
                [ SA.d d
                , SA.fill "none"
                , SA.stroke stroke
                , SA.strokeWidth "2.5"
                , SA.strokeLinecap "round"
                ]
                []
        radiusA = radiusB - 1
        radiusB = cellWidth * 0.27
    in
        Svg.g
            []
            [ path (colorFor theme tone |> Color.toCssString)
                <| describeArc
                    center
                    { radiusA = radiusA, radiusB = radiusB }
                    { from = toAngle 0, to = toAngle value }
            , path (knobLine theme |> Color.toCssString)
                <| describeArc
                    center
                    { radiusA = radiusA, radiusB = radiusB }
                    { from = toAngle value, to = toAngle 1 }
            , path (colorFor theme tone |> Color.toCssString)
                <| describeMark
                    center
                    { radiusA = radiusA, radiusB = radiusB }
                    (toAngle value)
            ]


arrow : Theme -> Tone -> GroupState -> { x : Float, y : Float } -> Svg msg
arrow theme tone groupState center =
    Svg.g
        [ SA.style <|
            "transform: "
                ++ "translate(" ++ String.fromFloat (center.x - (14 * 0.7)) ++ "px,"
                                ++ String.fromFloat (center.y - (14 * 0.7)) ++ "px)"
        ]
        [ Util.arrow (colorFor theme tone) (scale 0.7) <| case groupState of
                Expanded -> rotate 180
                Detached -> rotate 45
                Collapsed -> rotate 0
        ]

button : Theme -> Tone -> Maybe Icon -> { x : Float, y : Float } -> Svg msg
button theme tone maybeIcon center =
    case maybeIcon of
        Just (Icon icon) ->
            let
                postfix =
                    case theme of
                        Dark -> "dark"
                        Light -> "light"
                iconUrl =
                    "./assets/" ++ icon ++ "_" ++ postfix ++ ".svg"
            in
                Svg.image
                    [ SA.xlinkHref <| iconUrl
                    , SA.class "button--icon"
                    , SA.width "35px"
                    , SA.height "35px"
                    , SA.x "18"
                    , SA.y "15"
                    ]
                    []
        Nothing ->
            Svg.rect
                [ SA.x <| String.fromFloat (center.x - 10)
                , SA.y <| String.fromFloat (center.y - 12)
                , SA.width "20"
                , SA.height "20"
                , SA.fill "none"
                , SA.stroke <| Color.toCssString <| colorFor theme tone
                , SA.strokeWidth "2.5"
                , SA.strokeLinecap "round"
                , SA.rx "3"
                , SA.ry "3"
                ]
                [
                ]


color : Theme -> Tone -> Color -> { x : Float, y : Float } -> Svg msg
color theme tone value center =
    Svg.rect
        [ SA.x <| String.fromFloat (center.x - 10)
        , SA.y <| String.fromFloat (center.y - 12)
        , SA.width "20"
        , SA.height "20"
        , SA.fill <| Color.toCssString value
        , SA.stroke <| Color.toCssString <| colorFor theme tone
        , SA.strokeWidth "2.5"
        , SA.strokeLinecap "round"
        , SA.rx "3"
        , SA.ry "3"
        ]
        [
        ]



toggle : Theme -> Tone -> ToggleState -> { x : Float, y : Float } -> Svg msg
toggle theme tone state center =
    Svg.circle
        [ SA.cx <| String.fromFloat center.x
        , SA.cy <| String.fromFloat center.y
        , SA.r "10"
        , SA.fill <| case state of
            TurnedOn -> Color.toCssString <| colorFor theme tone
            TurnedOff -> "none"
        , SA.stroke <| Color.toCssString <| colorFor theme tone
        , SA.strokeWidth "2.5"
        ]
        [
        ]


coord : Theme -> Tone -> { x : Float, y : Float } -> ( Float, Float ) -> Svg msg
coord theme tone center ( valueX, valueY ) =
    Svg.g
        []
        [ Svg.rect
            [ SA.x <| String.fromFloat (center.x - 10)
            , SA.y <| String.fromFloat (center.y - 12)
            , SA.width "20"
            , SA.height "20"
            , SA.fill "none"
            , SA.stroke <| Color.toCssString <| colorFor theme tone
            , SA.strokeWidth "2.5"
            , SA.strokeLinecap "round"
            , SA.strokeDasharray "2.5 15 5 15 5 15 5 15 2.5"
            -- , SA.rx "3"
            -- , SA.ry "3"
            ]
            [
            ]
        , Svg.circle
            [ SA.cx <| String.fromFloat <| center.x + ((valueX - 0.5) * 20)
            , SA.cy <| String.fromFloat <| center.y - 2 + ((valueY - 0.5) * 20)
            , SA.fill <| Color.toCssString <| colorFor theme tone
            , SA.stroke "none"
            , SA.r "3"
            ]
            []
        ]
-- 5 30 10 30 10 30 10 30 5


makeClass : Property msg -> String
makeClass prop =
    "cell " ++ case prop of
        Nil -> "ghost"
        Number _ -> "number"
        Coordinate _ -> "coord"
        Text _ -> "text"
        Color _ -> "color"
        Toggle _ -> "toggle"
        Action _ -> "button"
        Choice _ -> "choice"
        Group _ -> "group"
