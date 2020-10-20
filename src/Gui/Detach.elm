module Gui.Detach exposing (..)


import Url exposing (Url)
import Url.Builder as Url
import Random
import Dict
import HashId exposing (HashId)

import Gui.Path as Path exposing (Path, toList)
import Gui.Expose as Exp
import Gui.Property exposing (Property)
import Gui.Msg exposing (Msg(..))


type alias Fragment = ( String, String )


type alias LocalUrl = List Fragment


type alias ClientId = HashId


type State
    = Detached
    | AttachedAt Path


type Detach msg =
    Detach
        { toUrl : ClientId -> Path -> Maybe LocalUrl
        , ack : Exp.Ack -> Cmd msg
        , send : Exp.RawUpdate -> Cmd msg
        , receive : ((Exp.RawUpdate -> Msg) -> Sub Msg)
        , attached : State
        , client : Maybe ClientId
        }


map : (msgA -> msgB) -> Detach msgA -> Detach msgB
map f (Detach d) =
    Detach
        { toUrl = d.toUrl
        , send = d.send >> Cmd.map f
        , ack = d.ack >> Cmd.map f
        , receive = d.receive
        , attached = d.attached
        , client = d.client
        }


never : Detach msg
never =
    Detach
        { toUrl = always <| always Nothing
        , ack = always Cmd.none
        , send = always Cmd.none
        , receive = always Sub.none
        , attached = attachedAtRoot
        , client = Nothing
        }


nextClientId : Cmd Msg
nextClientId =
    Random.generate SetClientId HashId.generator


setClientId : ClientId -> Detach msg -> Detach msg
setClientId clientId (Detach d) =
    Detach
        { d
        | client = Just clientId
        }


detached : State
detached = Detached


attachedAt : Path -> State
attachedAt = AttachedAt


attachedAtRoot : State
attachedAtRoot = AttachedAt Path.start


getLocalUrl : Path -> Detach msg -> Maybe LocalUrl
getLocalUrl path (Detach d) =
    case d.client of
        Just clientId -> d.toUrl clientId path
        Nothing -> Nothing


root : String
root = "root"


formLocalUrl : ClientId -> Path -> Maybe LocalUrl
formLocalUrl client path =
    Just
        [ ( "client", HashId.toString client )
        , ( "path"
          , if Path.howDeep path == 0 then
                root
            else
                path
                |> Path.toList
                |> List.map String.fromInt
                |> String.join "-"
            )
        ]


localUrlToString : LocalUrl -> String
localUrlToString fragments =
    let
        encodeFragment ( k, v ) =
            k ++ "=" ++ v
    in

    "#" ++ (String.join "&" <| List.map encodeFragment <| fragments)


make
     : Url
    -> (Exp.Ack -> Cmd msg)
    -> (Exp.RawUpdate -> Cmd msg)
    -> ((Exp.RawUpdate -> Msg) -> Sub Msg)
    -> ( Detach msg, Cmd Msg )
make url ackPort sendPort receivePort =
    let
        ( maybeClient, state ) = fromUrl url
    in
        ( Detach
            { toUrl = formLocalUrl
            , ack = ackPort
            , send = sendPort
            , receive = receivePort
            , attached = state
            , client = maybeClient
            }
        , case maybeClient of
            Nothing -> nextClientId
            _ -> Cmd.none
        )


-- extract : Url -> List Path
-- extract


ack : Detach msg -> Cmd msg
ack (Detach d) =
    d.ack <| Exp.encodeAck d.client


send : Detach msg -> Path -> Property msg -> Cmd msg
send (Detach d) path =
    d.send << Exp.encodeUpdate d.client path


receive : Detach msg -> Sub Msg
receive (Detach d) =
    d.receive ReceiveRaw


fromUrl : Url -> ( Maybe ClientId, State )
fromUrl { fragment } =
    let
        extractFragment str =
            case str |> String.split "=" of
                k::v::_ -> Just ( k, v )
                _ -> Nothing
    in case fragment of
        Just str ->
            let
                fragments =
                    str
                        |> String.split "&"
                        |> List.filterMap extractFragment
                        |> Dict.fromList
            in
                ( fragments
                    |> Dict.get "client"
                    |> Maybe.map HashId.fromString
                , case fragments |> Dict.get "path" of
                    Just pathStr ->
                        if pathStr == root
                        then AttachedAt Path.start
                        else
                            pathStr
                                |> String.split "-"
                                |> List.map String.toInt
                                |> List.filterMap identity
                                |> Path.fromList
                                |> AttachedAt
                    Nothing -> Detached
                )
        Nothing -> ( Nothing, Detached )


isAttached : Detach msg -> Maybe Path
isAttached (Detach d) =
    d.attached |> stateToMaybe


stateToMaybe : State -> Maybe Path
stateToMaybe state =
    case state of
        Detached -> Nothing
        AttachedAt path -> Just path
