// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class MyFolderQuery: GraphQLQuery {
  public static let operationName: String = "myFolder"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query myFolder { folders { __typename ...FolderFrag } }"#,
      fragments: [FolderFrag.self]
    ))

  public init() {}

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("folders", [Folder?].self),
    ] }

    public var folders: [Folder?] { __data["folders"] }

    /// Folder
    ///
    /// Parent Type: `Folder`
    public struct Folder: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Folder }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(FolderFrag.self),
      ] }

      public var id: KomiicAPI.ID { __data["id"] }
      public var key: String { __data["key"] }
      public var name: String { __data["name"] }
      public var views: Int? { __data["views"] }
      public var comicCount: Int { __data["comicCount"] }
      public var dateCreated: KomiicAPI.Time? { __data["dateCreated"] }
      public var dateUpdated: KomiicAPI.Time? { __data["dateUpdated"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var folderFrag: FolderFrag { _toFragment() }
      }
    }
  }
}