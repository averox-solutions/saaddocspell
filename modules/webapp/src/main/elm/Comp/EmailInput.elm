{-
   Copyright 2020 Eike K. & Contributors

   SPDX-License-Identifier: AGPL-3.0-or-later
-}


module Comp.EmailInput exposing
    ( Model
    , Msg
    , ViewSettings
    , init
    , update
    , view2
    )

import Api
import Api.Model.ContactList exposing (ContactList)
import Data.ContactType
import Data.DropdownStyle as DS
import Data.Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onBlur, onClick, onInput)
import Http
import Styles as S
import Util.Html exposing (onKeyUp)
import Util.List
import Util.Maybe


type alias Model =
    { input : String
    , menuOpen : Bool
    , candidates : List String
    , active : Maybe String
    , backspaceCount : Int
    }


init : Model
init =
    { input = ""
    , menuOpen = False
    , candidates = []
    , active = Nothing
    , backspaceCount = 0
    }


type Msg
    = SetInput String
    | ContactResp (Result Http.Error ContactList)
    | KeyPress Int
    | AddEmail String
    | RemoveEmail String


getCandidates : Flags -> Model -> Cmd Msg
getCandidates flags model =
    case Util.Maybe.fromString model.input of
        Just q ->
            Api.getContacts flags (Just Data.ContactType.Email) (Just q) ContactResp

        Nothing ->
            Cmd.none


update : Flags -> List String -> Msg -> Model -> ( Model, Cmd Msg, List String )
update flags current msg model =
    case msg of
        SetInput str ->
            let
                nm =
                    { model | input = str, menuOpen = str /= "" }
            in
            ( nm, getCandidates flags nm, current )

        ContactResp (Ok list) ->
            ( { model
                | candidates = List.map .value (List.take 10 list.items)
                , active = Nothing
                , menuOpen = list.items /= []
              }
            , Cmd.none
            , current
            )

        ContactResp (Err _) ->
            ( model, Cmd.none, current )

        KeyPress code ->
            let
                addCurrent =
                    let
                        email =
                            Maybe.withDefault model.input model.active
                    in
                    if email == "" then
                        ( model, Cmd.none, current )

                    else
                        update flags current (AddEmail email) model

                removeLast =
                    ( { model | backspaceCount = 0 }, Cmd.none, Util.List.dropRight 1 current )
            in
            case Util.Html.intToKeyCode code of
                Just Util.Html.Up ->
                    let
                        prev =
                            case model.active of
                                Nothing ->
                                    List.reverse model.candidates
                                        |> List.head

                                Just act ->
                                    Util.List.findPrev (\e -> e == act) model.candidates
                    in
                    ( { model | active = prev }, Cmd.none, current )

                Just Util.Html.Down ->
                    let
                        next =
                            case model.active of
                                Nothing ->
                                    List.head model.candidates

                                Just act ->
                                    Util.List.findNext (\e -> e == act) model.candidates
                    in
                    ( { model | active = next }, Cmd.none, current )

                Just Util.Html.Enter ->
                    addCurrent

                Just Util.Html.Space ->
                    addCurrent

                Just Util.Html.Backspace ->
                    if model.backspaceCount >= 1 then
                        removeLast

                    else
                        ( { model | backspaceCount = model.backspaceCount + 1 }, Cmd.none, current )

                _ ->
                    ( model, Cmd.none, current )

        AddEmail str ->
            ( { model | input = "", menuOpen = False }
            , Cmd.none
            , Util.List.distinct (current ++ [ String.trim str ])
            )

        RemoveEmail str ->
            ( model, Cmd.none, List.filter (\e -> e /= str) current )



--- View2


type alias ViewSettings =
    { placeholder : String
    , style : DS.DropdownStyle
    }


view2 : ViewSettings -> List String -> Model -> Html Msg
view2 cfg values model =
    div [ class "text-sm flex-row space-x-2 relative" ]
        [ div
            [ class cfg.style.link
            , class "flex-wrap"
            ]
            [ div
                [ class "flex flex-row space-x-2 mr-2 flex-wrap"
                , classList [ ( "hidden", List.isEmpty values ) ]
                ]
                (List.map renderValue2 values)
            , input
                [ type_ "text"
                , value model.input
                , placeholder cfg.placeholder
                , onKeyUp KeyPress
                , onInput SetInput
                , if List.isEmpty model.candidates then
                    onBlur (KeyPress 13)

                  else
                    class ""
                , class "inline-flex w-24 border-0 px-0 focus:ring-0 h-6 text-sm"
                , class "placeholder-gray-400 dark:text-slate-200 dark:bg-slate-800 dark:border-slate-500"
                ]
                []
            ]
        , renderMenu2 cfg.style model
        ]


renderValue2 : String -> Html Msg
renderValue2 str =
    a
        [ class "label border-gray-400"
        , class S.border
        , href "#"
        , onClick (RemoveEmail str)
        ]
        [ span [ class "mr-1" ]
            [ text str
            ]
        , i [ class "fa fa-times" ] []
        ]


renderMenu2 : DS.DropdownStyle -> Model -> Html Msg
renderMenu2 style model =
    let
        mkItem v =
            a
                [ class style.item
                , classList
                    [ ( "bg-gray-200 dark:bg-slate-700 dark:text-slate-50", model.active == Just v )
                    ]
                , href "#"
                , onClick (AddEmail v)
                ]
                [ text v
                ]
    in
    div
        [ classList
            [ ( "hidden", not model.menuOpen )
            ]
        , class "-left-2"
        , class style.menu
        ]
        (List.map mkItem model.candidates)
