-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Github.Object.RepositoryTopic exposing (id, resourcePath, topic, url)

import Github.InputObject
import Github.Interface
import Github.Object
import Github.Scalar
import Github.ScalarDecoders
import Github.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


id : SelectionSet Github.ScalarDecoders.Id Github.Object.RepositoryTopic
id =
    Object.selectionForField "ScalarDecoders.Id" "id" [] (Github.ScalarDecoders.decoders |> Github.Scalar.unwrapDecoders |> .decoderId)


{-| The HTTP path for this repository-topic.
-}
resourcePath : SelectionSet Github.ScalarDecoders.Uri Github.Object.RepositoryTopic
resourcePath =
    Object.selectionForField "ScalarDecoders.Uri" "resourcePath" [] (Github.ScalarDecoders.decoders |> Github.Scalar.unwrapDecoders |> .decoderUri)


{-| The topic.
-}
topic : SelectionSet decodesTo Github.Object.Topic -> SelectionSet decodesTo Github.Object.RepositoryTopic
topic object_ =
    Object.selectionForCompositeField "topic" [] object_ identity


{-| The HTTP URL for this repository-topic.
-}
url : SelectionSet Github.ScalarDecoders.Uri Github.Object.RepositoryTopic
url =
    Object.selectionForField "ScalarDecoders.Uri" "url" [] (Github.ScalarDecoders.decoders |> Github.Scalar.unwrapDecoders |> .decoderUri)
