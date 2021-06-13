module Tron.Style.PanelShape exposing
    ( PanelShape
    , auto, rows, cols
    , by
    , distribute
    )


{-| # Panel Shape

Panel shape is how many cells the panel takes in the GUI grid (it is automatically calculated considering the fact that cells inside could be halflings or giants, see `CellShape`).

You are not required to specify both sides, just use `rows` or `cols` helpers to say how many rows or columns you want in the panel and other side will be calculated automatically. Or even use `auto` and both sides will be suggested, but this usually doesn't look good. To specify both sides manually, use `by`.

@docs PanelShape

# Automatic
@docs auto, rows, cols

# Manual
@docs by

# Helpers
@docs distribute
-}


import Tron.Style.CellShape exposing (CellShape(..), numify)
import Tron.Pages as Pages exposing (Pages)
import Size exposing (..)


{-| -}
type PanelShape
    = Auto
    | Rows Int
    | Cols Int
    | Shape Int Int


{-| Calculate both rows and column numbers automatically, based on the number of cells inside. -}
auto : PanelShape
auto = Auto


{-| Specify how many cell rows there should be in the panel, and calculate columns number automatically. -}
rows : Int -> PanelShape
rows = Rows


{-| Specify how many cell columns there should be in the panel, and calculate rows number automatically. -}
cols : Int -> PanelShape
cols = Cols


{-| Specify panel size manually, i.e. how many cells horizontally and how many vertically. -}
by : Int -> Int -> PanelShape
by = Shape


maxCols : Int
maxCols = 3


maxRows : Int
maxRows = 3


{-| Get numeric size of a panel in cells, and a set of pages required, if there are overflows. Floats, since there could be half-cells. -}
distribute : PanelShape -> CellShape -> List a -> ( Pages (List a), SizeF Cells )
distribute panelShape cellShape items =
    let
        itemCount = List.length items
        ( cellXMultiplier, cellYMultiplier ) =
            numify cellShape
        otherSide n =
            if (n /= 0) && (modBy n itemCount) == 0
                then itemCount // n
                else itemCount // n + 1
        onAPage ( c, r ) =
            ceiling
                ( toFloat c * cellXMultiplier
                * toFloat r * cellYMultiplier
                )
        pagesFor =
            Pages.distribute << onAPage

    in
        ( case panelShape of
            Auto ->
                let n = itemCount // 2
                in
                    ( n
                    , otherSide n
                    )
            Cols n ->
                ( n
                , otherSide n
                )
            Rows n ->
                ( otherSide n
                , n
                )
            Shape nc nr ->
                ( nc
                , nr
                )
        )
        |>
            (\(c, r) ->
                if c > maxCols
                then
                    ( pagesFor ( maxCols, r ) items
                    , ( maxCols, r )
                    )
                else if r > maxRows
                then
                    ( pagesFor ( c, maxRows ) items
                    , ( c, maxRows )
                    )
                else
                    ( Pages.single <| items
                    , (c, r)
                    )
            )
        |> Tuple.mapSecond
            (Tuple.mapBoth
                (\c -> toFloat c * cellXMultiplier)
                (\r -> toFloat r * cellYMultiplier)
                >> SizeF
            )
