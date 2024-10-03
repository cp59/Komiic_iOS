// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RemoveFolderMutation: GraphQLMutation {
  public static let operationName: String = "removeFolder"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation removeFolder($folderId: ID!) { removeFolder(folderId: $folderId) }"#
    ))

  public var folderId: ID

  public init(folderId: ID) {
    self.folderId = folderId
  }

  public var __variables: Variables? { ["folderId": folderId] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("removeFolder", Bool.self, arguments: ["folderId": .variable("folderId")]),
    ] }

    public var removeFolder: Bool { __data["removeFolder"] }
  }
}