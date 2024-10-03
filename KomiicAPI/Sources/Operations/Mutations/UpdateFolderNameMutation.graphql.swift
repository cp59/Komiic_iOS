// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateFolderNameMutation: GraphQLMutation {
  public static let operationName: String = "updateFolderName"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation updateFolderName($folderId: ID!, $name: String!) { updateFolderName(folderId: $folderId, name: $name) }"#
    ))

  public var folderId: ID
  public var name: String

  public init(
    folderId: ID,
    name: String
  ) {
    self.folderId = folderId
    self.name = name
  }

  public var __variables: Variables? { [
    "folderId": folderId,
    "name": name
  ] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateFolderName", Bool.self, arguments: [
        "folderId": .variable("folderId"),
        "name": .variable("name")
      ]),
    ] }

    public var updateFolderName: Bool { __data["updateFolderName"] }
  }
}