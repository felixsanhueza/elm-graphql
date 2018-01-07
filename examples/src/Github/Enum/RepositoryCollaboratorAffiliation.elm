-- Do not manually edit this file, it was auto-generated by Graphqelm
-- npm package version 0.0.13
-- Target elm package version 4.0.0
-- https://github.com/dillonkearns/graphqelm


module Github.Enum.RepositoryCollaboratorAffiliation exposing (..)

import Json.Decode as Decode exposing (Decoder)


{-| The affiliation type between collaborator and repository.

  - All - All collaborators of the repository.
  - Outside - All outside collaborators of an organization-owned repository.

-}
type RepositoryCollaboratorAffiliation
    = All
    | Outside


decoder : Decoder RepositoryCollaboratorAffiliation
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "ALL" ->
                        Decode.succeed All

                    "OUTSIDE" ->
                        Decode.succeed Outside

                    _ ->
                        Decode.fail ("Invalid RepositoryCollaboratorAffiliation type, " ++ string ++ " try re-running the graphqelm CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : RepositoryCollaboratorAffiliation -> String
toString enum =
    case enum of
        All ->
            "ALL"

        Outside ->
            "OUTSIDE"
