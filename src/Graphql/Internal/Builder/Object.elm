module Graphql.Internal.Builder.Object exposing
    ( fieldDecoder, interfaceSelection, unionSelection, scalarDecoder, exhuastiveFragmentSelection, buildFragment
    , selectionForField, selectionForCompositeField
    )

{-| **WARNING** `Graphql.Interal` modules are used by the `@dillonkearns/elm-graphql` command line
code generator tool. They should not be consumed through hand-written code.

Internal functions for use by auto-generated code from the `@dillonkearns/elm-graphql` CLI.

@docs fieldDecoder, interfaceSelection, unionSelection, scalarDecoder, exhuastiveFragmentSelection, buildFragment


## New API

@docs selectionForField, selectionForCompositeField

-}

import Dict
import Graphql.Document.Field
import Graphql.Internal.Builder.Argument exposing (Argument)
import Graphql.RawField exposing (RawField)
import Graphql.SelectionSet exposing (FragmentSelectionSet(..), SelectionSet(..))
import Json.Decode as Decode exposing (Decoder)
import String.Interpolate exposing (interpolate)


{-| Decoder for scalars for use in auto-generated code.
-}
scalarDecoder : Decoder String
scalarDecoder =
    Decode.oneOf
        [ Decode.string
        , Decode.float |> Decode.map String.fromFloat
        , Decode.int |> Decode.map String.fromInt
        , Decode.bool
            |> Decode.map
                (\bool ->
                    case bool of
                        True ->
                            "true"

                        False ->
                            "false"
                )
        ]


{-| Refer to a field in auto-generated code.
-}
fieldDecoder : String -> List Argument -> Decoder decodesTo -> SelectionSet decodesTo lockedTo
fieldDecoder =
    selectionForField


{-| Refer to a field in auto-generated code.
-}
selectionForField : String -> List Argument -> Decoder decodesTo -> SelectionSet decodesTo lockedTo
selectionForField fieldName args decoder =
    SelectionSet [ leaf fieldName args ]
        (Decode.field
            (Graphql.Document.Field.hashedAliasName (leaf fieldName args))
            decoder
        )


{-| Refer to an object in auto-generated code.
-}
selectionForCompositeField :
    String
    -> List Argument
    -> SelectionSet a objectTypeLock
    -> (Decoder a -> Decoder b)
    -> SelectionSet b lockedTo
selectionForCompositeField fieldName args (SelectionSet fields decoder) decoderTransform =
    SelectionSet [ composite fieldName args fields ]
        (Decode.field
            (Graphql.Document.Field.hashedAliasName (composite fieldName args fields))
            (decoderTransform decoder)
        )


composite : String -> List Argument -> List RawField -> RawField
composite fieldName args fields =
    Graphql.RawField.Composite fieldName args fields


leaf : String -> List Argument -> RawField
leaf fieldName args =
    Graphql.RawField.Leaf fieldName args


{-| Used to create FragmentSelectionSets for type-specific fragmentsin auto-generated code.
-}
buildFragment : String -> SelectionSet decodesTo selectionLock -> FragmentSelectionSet decodesTo fragmentLock
buildFragment fragmentTypeName (SelectionSet fields decoder) =
    FragmentSelectionSet fragmentTypeName fields decoder


{-| Used to create the `selection` functions in auto-generated code for interfaces.
-}
interfaceSelection : List (FragmentSelectionSet typeSpecific typeLock) -> (Maybe typeSpecific -> a -> b) -> SelectionSet (a -> b) typeLock
interfaceSelection typeSpecificSelections constructor =
    let
        typeNameDecoder =
            \typeName ->
                typeSpecificSelections
                    |> List.map (\(FragmentSelectionSet thisTypeName fields decoder) -> ( thisTypeName, decoder ))
                    |> Dict.fromList
                    |> Dict.get typeName
                    |> Maybe.map (Decode.map Just)
                    |> Maybe.withDefault (Decode.succeed Nothing)

        selections =
            typeSpecificSelections
                |> List.map (\(FragmentSelectionSet typeName fields decoder) -> composite ("...on " ++ typeName) [] fields)
    in
    SelectionSet (leaf "__typename" [] :: selections)
        (Decode.map2 (|>)
            (Decode.string
                |> Decode.field "__typename"
                |> Decode.andThen typeNameDecoder
            )
            (Decode.succeed constructor)
        )


{-| Used to create the `selection` functions in auto-generated code for exhuastive fragments.
-}
exhuastiveFragmentSelection : List (FragmentSelectionSet decodesTo typeLock) -> SelectionSet decodesTo typeLock
exhuastiveFragmentSelection typeSpecificSelections =
    let
        selections =
            typeSpecificSelections
                |> List.map (\(FragmentSelectionSet typeName fields decoder) -> composite ("...on " ++ typeName) [] fields)
    in
    SelectionSet (leaf "__typename" [] :: selections)
        (Decode.string
            |> Decode.field "__typename"
            |> Decode.andThen
                (\typeName ->
                    typeSpecificSelections
                        |> List.map (\(FragmentSelectionSet thisTypeName fields decoder) -> ( thisTypeName, decoder ))
                        |> Dict.fromList
                        |> Dict.get typeName
                        |> Maybe.withDefault (exhaustiveFailureMessage typeSpecificSelections typeName |> Decode.fail)
                )
        )


exhaustiveFailureMessage typeSpecificSelections typeName =
    interpolate
        "Unhandled type `{0}` in exhaustive fragment handling. The following types had handlers registered to handle them: [{1}]. This happens if you are parsing either a Union or Interface. Do you need to rerun the `@dillonkearns/elm-graphql` command line tool?"
        [ typeName, typeSpecificSelections |> List.map (\(FragmentSelectionSet fragmentType fields decoder) -> fragmentType) |> String.join ", " ]


{-| Used to create the `selection` functions in auto-generated code for unions.
-}
unionSelection : List (FragmentSelectionSet typeSpecific typeLock) -> (Maybe typeSpecific -> a) -> SelectionSet a typeLock
unionSelection typeSpecificSelections constructor =
    let
        typeNameDecoder =
            \typeName ->
                typeSpecificSelections
                    |> List.map (\(FragmentSelectionSet thisTypeName fields decoder) -> ( thisTypeName, decoder ))
                    |> Dict.fromList
                    |> Dict.get typeName
                    |> Maybe.map (Decode.map Just)
                    |> Maybe.withDefault (Decode.succeed Nothing)

        selections =
            typeSpecificSelections
                |> List.map (\(FragmentSelectionSet typeName fields decoder) -> composite ("...on " ++ typeName) [] fields)
    in
    SelectionSet (leaf "__typename" [] :: selections)
        (Decode.map2 (|>)
            (Decode.string
                |> Decode.field "__typename"
                |> Decode.andThen typeNameDecoder
            )
            (Decode.succeed constructor)
        )
