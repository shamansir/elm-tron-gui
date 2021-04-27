port module ReportToJsBacked.Main exposing (..)


import Tron.Style.Theme as Theme
import Tron.Style.Dock as Dock
import Tron.Option as Option
import Tron.Expose.Data as Exp
import WithTron exposing (BackedWithTron)


import Example.Tiler.Gui as ExampleGui


port ack : Exp.RawProperty -> Cmd msg

port transmit : Exp.RawOutUpdate -> Cmd msg


main : BackedWithTron
main =
    WithTron.backed
        (Option.toHtml Dock.middleRight Theme.dark)
        ( ack, transmit )
        ExampleGui.gui


