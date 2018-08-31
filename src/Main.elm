port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events
import Http
import Json.Decode as Decode
import Task
import Time
import Url.Builder as Url



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone, time : Time.Posix, content : List String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0) [ "Hello World" ], Task.perform AdjustTimeZone Time.here )


fileDecoder : Decode.Decoder (List String)
fileDecoder =
    Decode.field "files" (Decode.list Decode.string)



-- UPDATE


type Msg
    = RefreshFiles
    | FilesRefreshed (Result Http.Error (List String))
    | AdjustTimeZone Time.Zone
    | Tick Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RefreshFiles ->
            ( model, Cmd.none )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        Tick newTime ->
            ( { model | time = newTime }
            , refreshFiles
            )

        FilesRefreshed result ->
            case result of
                Ok files ->
                    ( { model | content = files }, Cmd.none )

                Err error ->
                    case error of
                        Http.Timeout ->
                            ( { model | content = [ "Timeout" ] }, Cmd.none )

                        Http.NetworkError ->
                            ( { model | content = [ "Network Error" ] }, Cmd.none )

                        Http.BadStatus pl ->
                            ( { model | content = [ "PL" ] }, Cmd.none )

                        Http.BadPayload s s2 ->
                            ( { model | content = [ s2.body ] }, Cmd.none )

                        Http.BadUrl _ ->
                            ( { model | content = [ "URL" ] }, Cmd.none )



-- SUBSCRIPTIONS


refreshFiles : Cmd Msg
refreshFiles =
    Http.send FilesRefreshed (Http.get "http://37.139.3.80:3000/files" fileDecoder)


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ h1 [] [ text (String.concat model.content) ] ]
