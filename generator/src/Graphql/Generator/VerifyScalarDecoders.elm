module Graphql.Generator.VerifyScalarDecoders exposing (generate)

import Graphql.Generator.Context exposing (Context)
import Graphql.Parser.ClassCaseName as ClassCaseName exposing (ClassCaseName)
import Graphql.Parser.Type as Type exposing (TypeDefinition(..))
import ModuleName
import String.Interpolate exposing (interpolate)


generate : Context -> List TypeDefinition -> ( List String, String )
generate context typeDefs =
    ( context.apiSubmodule ++ [ "VerifyScalarDecoders" ], fileContents context typeDefs )


include : TypeDefinition -> Bool
include (TypeDefinition name definableType description) =
    isScalar definableType
        && not (isBuiltIn name)


builtInNames : List String
builtInNames =
    [ "Boolean"
    , "String"
    , "Int"
    , "Float"
    ]


isBuiltIn : ClassCaseName -> Bool
isBuiltIn name =
    List.member (ClassCaseName.raw name) builtInNames


isScalar : Type.DefinableType -> Bool
isScalar definableType =
    case definableType of
        Type.ScalarType ->
            True

        _ ->
            False


fileContents : Context -> List TypeDefinition -> String
fileContents context typeDefinitions =
    let
        typesToGenerate =
            typeDefinitions
                |> List.filter include
                |> List.map (\(TypeDefinition name definableType description) -> name)

        moduleName =
            context.apiSubmodule ++ [ "VerifyScalarDecoders" ] |> String.join "."

        placeholderCode =
            interpolate
                """module {0} exposing (..)


placeholder : String
placeholder =
""
"""
                [ moduleName ]
    in
    case ( typesToGenerate, context.scalarDecodersModule ) of
        ( _, Nothing ) ->
            placeholderCode

        ( [], _ ) ->
            placeholderCode

        ( _, Just scalarDecodersModule ) ->
            interpolate
                """module {0} exposing (..)


{-
  This file is intended to be used to ensure that custom scalar decoder
  files are valid. It is compiled using `elm make` by the CLI.
-}

import {3}.Scalar
import {1}


verify : {3}.Scalar.Decoders {2}
verify =
    {1}.decoders
"""
                [ moduleName
                , scalarDecodersModule |> ModuleName.toString
                , typesToGenerate
                    |> List.map
                        (\classCaseName ->
                            ModuleName.append
                                (ClassCaseName.normalized classCaseName)
                                scalarDecodersModule
                        )
                    |> String.join " "
                , context.apiSubmodule |> String.join "."
                ]
