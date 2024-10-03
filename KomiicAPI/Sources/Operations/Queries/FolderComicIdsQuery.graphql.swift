// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FolderComicIdsQuery: GraphQLQuery {
  public static let operationName: String = "folderComicIds"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query folderComicIds($folderId: ID!, $pagination: Pagination!) { folderComicIds(folderId: $folderId, pagination: $pagination) { folderId key comicIds __typename } }"#
    ))

  public var folderId: ID
  public var pagination: Pagination

  public init(
    folderId: ID,
    pagination: Pagination
  ) {
    self.folderId = folderId
    self.pagination = pagination
  }

  public var __variables: Variables? { [
    "folderId": folderId,
    "pagination": pagination
  ] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("folderComicIds", FolderComicIds.self, arguments: [
        "folderId": .variable("folderId"),
        "pagination": .variable("pagination")
      ]),
    ] }

    public var folderComicIds: FolderComicIds { __data["folderComicIds"] }

    /// FolderComicIds
    ///
    /// Parent Type: `FolderComicIds`
    public struct FolderComicIds: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.FolderComicIds }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("folderId", KomiicAPI.ID.self),
        .field("key", String.self),
        .field("comicIds", [KomiicAPI.ID?].self),
      ] }

      public var folderId: KomiicAPI.ID { __data["folderId"] }
      public var key: String { __data["key"] }
      public var comicIds: [KomiicAPI.ID?] { __data["comicIds"] }
    }
  }
}