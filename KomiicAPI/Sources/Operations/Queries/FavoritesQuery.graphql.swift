// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FavoritesQuery: GraphQLQuery {
  public static let operationName: String = "favoritesQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query favoritesQuery($pagination: Pagination!) { getLatestUpdatedDateInFavorite favoritesV2(pagination: $pagination) { id comicId dateAdded lastAccess bookReadProgress chapterReadProgress __typename } }"#
    ))

  public var pagination: Pagination

  public init(pagination: Pagination) {
    self.pagination = pagination
  }

  public var __variables: Variables? { ["pagination": pagination] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getLatestUpdatedDateInFavorite", KomiicAPI.Time.self),
      .field("favoritesV2", [FavoritesV2?].self, arguments: ["pagination": .variable("pagination")]),
    ] }

    public var getLatestUpdatedDateInFavorite: KomiicAPI.Time { __data["getLatestUpdatedDateInFavorite"] }
    public var favoritesV2: [FavoritesV2?] { __data["favoritesV2"] }

    /// FavoritesV2
    ///
    /// Parent Type: `FavoriteV2`
    public struct FavoritesV2: KomiicAPI.SelectionSet {
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