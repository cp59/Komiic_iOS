// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ReadComicHistoryQuery: GraphQLQuery {
  public static let operationName: String = "readComicHistory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query readComicHistory($pagination: Pagination!) { readComicHistory(pagination: $pagination) { id comicId chapters { id chapterId page __typename } startDate lastDate chapterType __typename } }"#
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
      .field("readComicHistory", [ReadComicHistory?].self, arguments: ["pagination": .variable("pagination")]),
    ] }

    public var readComicHistory: [ReadComicHistory?] { __data["readComicHistory"] }

    /// ReadComicHistory
    ///
    /// Parent Type: `ReadComicHistory`
    public struct ReadComicHistory: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.ReadComicHistory }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KomiicAPI.ID.self),
        .field("comicId", KomiicAPI.ID.self),
        .field("chapters", [Chapter?].self),
        .field("startDate", KomiicAPI.Time?.self),
        .field("lastDate", KomiicAPI.Time?.self),
        .field("chapterType", String?.self),
      ] }

      public var id: KomiicAPI.ID { __data["id"] }
      public var comicId: KomiicAPI.ID { __data["comicId"] }
      public var chapters: [Chapter?] { __data["chapters"] }
      public var startDate: KomiicAPI.Time? { __data["startDate"] }
      public var lastDate: KomiicAPI.Time? { __data["lastDate"] }
      public var chapterType: String? { __data["chapterType"] }

      /// ReadComicHistory.Chapter
      ///
      /// Parent Type: `ReadChapterHistory`
      public struct Chapter: KomiicAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.ReadChapterHistory }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", KomiicAPI.ID.self),
          .field("chapterId", KomiicAPI.ID.self),
          .field("page", Int.self),
        ] }

        public var id: KomiicAPI.ID { __data["id"] }
        public var chapterId: KomiicAPI.ID { __data["chapterId"] }
        public var page: Int { __data["page"] }
      }
    }
  }
}