// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateFolderMutation: GraphQLMutation {
  public static let operationName: String = "createFolder"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation createFolder($name: String!) { createFolder(name: $name) { __typename ...FolderFrag } }"#,
      fragments: [FolderFrag.self]
    ))

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var __variables: Variables? { ["name": name] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createFolder", CreateFolder.self, arguments: ["name": .variable("name")]),
    ] }

    public var createFolder: CreateFolder { __data["createFolder"] }

    /// CreateFolder
    ///
    /// Parent Type: `Folder`
    public struct CreateFolder: KomiicAPI.SelectionSet {
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