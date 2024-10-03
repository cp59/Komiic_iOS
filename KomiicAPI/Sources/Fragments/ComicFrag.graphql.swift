// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ComicFrag: KomiicAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ComicFrag on Comic { __typename id title status year imageUrl authors { __typename id name } categories { __typename id name } dateUpdated monthViews views favoriteCount lastBookUpdate lastChapterUpdate }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Comic }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", KomiicAPI.ID.self),
    .field("title", String.self),
    .field("status", String.self),
    .field("year", Int.self),
    .field("imageUrl", String.self),
    .field("authors", [Author?].self),
    .field("categories", [Category?].self),
    .field("dateUpdated", KomiicAPI.Time?.self),
    .field("monthViews", Int?.self),
    .field("views", Int?.self),
    .field("favoriteCount", Int.self),
    .field("lastBookUpdate", String?.self),
    .field("lastChapterUpdate", String?.self),
  ] }

  public var id: KomiicAPI.ID { __data["id"] }
  public var title: String { __data["title"] }
  public var status: String { __data["status"] }
  public var year: Int { __data["year"] }
  public var imageUrl: String { __data["imageUrl"] }
  public var authors: [Author?] { __data["authors"] }
  public var categories: [Category?] { __data["categories"] }
  public var dateUpdated: KomiicAPI.Time? { __data["dateUpdated"] }
  public var monthViews: Int? { __data["monthViews"] }
  public var views: Int? { __data["views"] }
  public var favoriteCount: Int { __data["favoriteCount"] }
  public var lastBookUpdate: String? { __data["lastBookUpdate"] }
  public var lastChapterUpdate: String? { __data["lastChapterUpdate"] }

  /// Author
  ///
  /// Parent Type: `Author`
  public struct Author: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Author }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", KomiicAPI.ID.self),
      .field("name", String.self),
    ] }

    public var id: KomiicAPI.ID { __data["id"] }
    public var name: String { __data["name"] }
  }

  /// Category
  ///
  /// Parent Type: `Category`
  public struct Category: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Category }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", KomiicAPI.ID.self),
      .field("name", String.self),
    ] }

    public var id: KomiicAPI.ID { __data["id"] }
    public var name: String { __data["name"] }
  }
}
