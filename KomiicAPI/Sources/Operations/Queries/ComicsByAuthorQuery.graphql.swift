// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ComicsByAuthorQuery: GraphQLQuery {
  public static let operationName: String = "comicsByAuthor"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query comicsByAuthor($authorId: ID!) { getComicsByAuthor(authorId: $authorId) { __typename ...ComicFrag } }"#,
      fragments: [ComicFrag.self]
    ))

  public var authorId: ID

  public init(authorId: ID) {
    self.authorId = authorId
  }

  public var __variables: Variables? { ["authorId": authorId] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getComicsByAuthor", [GetComicsByAuthor?].self, arguments: ["authorId": .variable("authorId")]),
    ] }

    public var getComicsByAuthor: [GetComicsByAuthor?] { __data["getComicsByAuthor"] }

    /// GetComicsByAuthor
    ///
    /// Parent Type: `Comic`
    public struct GetComicsByAuthor: KomiicAPI.SelectionSet {
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