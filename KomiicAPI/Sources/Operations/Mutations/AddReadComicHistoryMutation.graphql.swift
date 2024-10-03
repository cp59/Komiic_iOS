// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AddReadComicHistoryMutation: GraphQLMutation {
  public static let operationName: String = "addReadComicHistory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation addReadComicHistory($comicId: ID!, $chapterId: ID!, $page: Int!) { addReadComicHistory(comicId: $comicId, chapterId: $chapterId, page: $page) { id comicId chapters { id chapterId page __typename } startDate lastDate chapterType __typename } }"#
    ))

  public var comicId: ID
  public var chapterId: ID
  public var page: Int

  public init(
    comicId: ID,
    chapterId: ID,
    page: Int
  ) {
    self.comicId = comicId
    self.chapterId = chapterId
    self.page = page
  }

  public var __variables: Variables? { [
    "comicId": comicId,
    "chapterId": chapterId,
    "page": page
  ] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("addReadComicHistory", AddReadComicHistory.self, arguments: [
        "comicId": .variable("comicId"),
        "chapterId": .variable("chapterId"),
        "page": .variable("page")
      ]),
    ] }

    public var addReadComicHistory: AddReadComicHistory { __data["addReadComicHistory"] }

    /// AddReadComicHistory
    ///
    /// Parent Type: `ReadComicHistory`
    public struct AddReadComicHistory: KomiicAPI.SelectionSet {
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

      /// AddReadComicHistory.Chapter
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