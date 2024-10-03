// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ChapterByComicIdQuery: GraphQLQuery {
  public static let operationName: String = "chapterByComicId"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query chapterByComicId($comicId: ID!) { chaptersByComicId(comicId: $comicId) { id serial type dateCreated dateUpdated size __typename } }"#
    ))

  public var comicId: ID

  public init(comicId: ID) {
    self.comicId = comicId
  }

  public var __variables: Variables? { ["comicId": comicId] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("chaptersByComicId", [ChaptersByComicId?].self, arguments: ["comicId": .variable("comicId")]),
    ] }

    public var chaptersByComicId: [ChaptersByComicId?] { __data["chaptersByComicId"] }

    /// ChaptersByComicId
    ///
    /// Parent Type: `Chapter`
    public struct ChaptersByComicId: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Chapter }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KomiicAPI.ID.self),
        .field("serial", String.self),
        .field("type", String.self),
        .field("dateCreated", KomiicAPI.Time?.self),
        .field("dateUpdated", KomiicAPI.Time?.self),
        .field("size", Int.self),
      ] }

      public var id: KomiicAPI.ID { __data["id"] }
      public var serial: String { __data["serial"] }
      public var type: String { __data["type"] }
      public var dateCreated: KomiicAPI.Time? { __data["dateCreated"] }
      public var dateUpdated: KomiicAPI.Time? { __data["dateUpdated"] }
      public var size: Int { __data["size"] }
    }
  }
}