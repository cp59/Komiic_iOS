// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AddFavoriteMutation: GraphQLMutation {
  public static let operationName: String = "addFavorite"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation addFavorite($comicId: ID!) { addFavorite(comicId: $comicId) { id comicId dateAdded lastAccess bookReadProgress chapterReadProgress __typename } }"#
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
      .field("addFavorite", AddFavorite.self, arguments: ["comicId": .variable("comicId")]),
    ] }

    public var addFavorite: AddFavorite { __data["addFavorite"] }

    /// AddFavorite
    ///
    /// Parent Type: `FavoriteV2`
    public struct AddFavorite: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.FavoriteV2 }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KomiicAPI.ID.self),
        .field("comicId", KomiicAPI.ID.self),
        .field("dateAdded", KomiicAPI.Time.self),
        .field("lastAccess", KomiicAPI.Time.self),
        .field("bookReadProgress", GraphQLEnum<KomiicAPI.ReadProgressType>?.self),
        .field("chapterReadProgress", GraphQLEnum<KomiicAPI.ReadProgressType>?.self),
      ] }

      public var id: KomiicAPI.ID { __data["id"] }
      public var comicId: KomiicAPI.ID { __data["comicId"] }
      public var dateAdded: KomiicAPI.Time { __data["dateAdded"] }
      public var lastAccess: KomiicAPI.Time { __data["lastAccess"] }
      public var bookReadProgress: GraphQLEnum<KomiicAPI.ReadProgressType>? { __data["bookReadProgress"] }
      public var chapterReadProgress: GraphQLEnum<KomiicAPI.ReadProgressType>? { __data["chapterReadProgress"] }
    }
  }
}