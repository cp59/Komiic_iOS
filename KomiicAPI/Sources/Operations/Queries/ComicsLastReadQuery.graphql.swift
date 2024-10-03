// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ComicsLastReadQuery: GraphQLQuery {
  public static let operationName: String = "comicsLastRead"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query comicsLastRead($comicIds: [ID]!) { lastReadByComicIds(comicIds: $comicIds) { comicId book { page chapterId serial __typename } chapter { page chapterId serial __typename } __typename } }"#
    ))

  public var comicIds: [ID?]

  public init(comicIds: [ID?]) {
    self.comicIds = comicIds
  }

  public var __variables: Variables? { ["comicIds": comicIds] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("lastReadByComicIds", [LastReadByComicId?].self, arguments: ["comicIds": .variable("comicIds")]),
    ] }

    public var lastReadByComicIds: [LastReadByComicId?] { __data["lastReadByComicIds"] }

    /// LastReadByComicId
    ///
    /// Parent Type: `ComicLastReadObj`
    public struct LastReadByComicId: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.ComicLastReadObj }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("comicId", KomiicAPI.ID.self),
        .field("book", Book?.self),
        .field("chapter", Chapter?.self),
      ] }

      public var comicId: KomiicAPI.ID { __data["comicId"] }
      public var book: Book? { __data["book"] }
      public var chapter: Chapter? { __data["chapter"] }

      /// LastReadByComicId.Book
      ///
      /// Parent Type: `ComicLastRead`
      public struct Book: KomiicAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.ComicLastRead }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("page", Int.self),
          .field("chapterId", KomiicAPI.ID.self),
          .field("serial", String.self),
        ] }

        public var page: Int { __data["page"] }
        public var chapterId: KomiicAPI.ID { __data["chapterId"] }
        public var serial: String { __data["serial"] }
      }

      /// LastReadByComicId.Chapter
      ///
      /// Parent Type: `ComicLastRead`
      public struct Chapter: KomiicAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.ComicLastRead }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("page", Int.self),
          .field("chapterId", KomiicAPI.ID.self),
          .field("serial", String.self),
        ] }

        public var page: Int { __data["page"] }
        public var chapterId: KomiicAPI.ID { __data["chapterId"] }
        public var serial: String { __data["serial"] }
      }
    }
  }
}