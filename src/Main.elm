module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Http
import Json.Decode as Decoder exposing (Decoder, at, field, int, list, string)
import Time



-- MAIN


main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }



-- MODEL


type Msg
    = FetchNewFiles Time.Posix
    | FilesFetched (Result Http.Error (List File))


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model []
    , fetchFiles
    )


type alias File =
    { filename : String }


type alias Model =
    { files : List File }


fileListDecoder : Decoder (List File)
fileListDecoder =
    at [ "files" ] (list fileDecoder)


fileDecoder : Decoder File
fileDecoder =
    Decoder.map File (field "filename" string)



-- UPDATE


fetchFiles : Cmd Msg
fetchFiles =
    Http.send FilesFetched (Http.get "http://37.139.3.80/elm-image-browser/db.json" fileListDecoder)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchNewFiles newTime ->
            ( model, fetchFiles )

        FilesFetched result ->
            case result of
                Ok newList ->
                    ( { model | files = newList }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 FetchNewFiles



-- VIEW


toHtmlList : List File -> Html msg
toHtmlList files =
    div [] (List.map (\l -> img [ class "image", src ("images/" ++ l.filename) ] []) files)


view : Model -> Html Msg
view model =
    div [] [ toHtmlList model.files ]
