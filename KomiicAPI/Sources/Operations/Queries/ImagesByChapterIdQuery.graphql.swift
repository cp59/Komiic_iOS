// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ImagesByChapterIdQuery: GraphQLQuery {
  public static let operationName: String = "imagesByChapterId"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query imagesByChapterId($chapterId: ID!) { imagesByChapterId(chapterId: $chapterId) { __typename id kid height width } }"#
    ))

  public var chapterId: ID

  public init(chapterId: ID) {
    self.chapterId = chapterId
  }

  public var __variables: Variables? { ["chapterId": chapterId] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("imagesByChapterId", [ImagesByChapterId?].self, arguments: ["chapterId": .variable("chapterId")]),
    ] }

    public var imagesByChapterId: [ImagesByChapterId?] { __data["imagesByChapterId"] }

    /// ImagesByChapterId
    ///
    /// Parent Type: `Image`
    public struct ImagesByChapterId: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Image }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KomiicAPI.ID.self),
        .field("kid", String.self),
        .field("height", Int.self),
        .field("width", Int.self),
      ] }

      public var id: KomiicAPI.ID { __data["id"] }
      public var kid: String { __data["kid"] }
      public var height: Int { __data["height"] }
      public var width: Int { __data["width"] }
    }
  }
}