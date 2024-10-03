// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RecentUpdateQuery: GraphQLQuery {
  public static let operationName: String = "recentUpdate"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query recentUpdate($pagination: Pagination!) { recentUpdate(pagination: $pagination) { __typename ...ComicFrag } }"#,
      fragments: [ComicFrag.self]
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
      .field("recentUpdate", [RecentUpdate?]?.self, arguments: ["pagination": .variable("pagination")]),
    ] }

    public var recentUpdate: [RecentUpdate?]? { __data["recentUpdate"] }

    /// RecentUpdate
    ///
    /// Parent Type: `Comic`
    public struct RecentUpdate: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Comic }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ComicFrag.self),
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

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var comicFrag: ComicFrag { _toFragment() }
      }

      public typealias Author = ComicFrag.Author

      public typealias Category = ComicFrag.Category
    }
  }
}