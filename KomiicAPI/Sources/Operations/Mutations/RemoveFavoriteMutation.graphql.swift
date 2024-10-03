// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RemoveFavoriteMutation: GraphQLMutation {
  public static let operationName: String = "removeFavorite"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation removeFavorite($comicId: ID!) { removeFavorite(comicId: $comicId) }"#
    ))

  public var comicId: ID

  public init(comicId: ID) {
    self.comicId = comicId
  }

  public var __variables: Variables? { ["comicId": comicId] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("removeFavorite", Bool.self, arguments: ["comicId": .variable("comicId")]),
    ] }

    public var removeFavorite: Bool { __data["removeFavorite"] }
  }
}