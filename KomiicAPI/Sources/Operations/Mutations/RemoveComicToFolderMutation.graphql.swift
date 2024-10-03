// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RemoveComicToFolderMutation: GraphQLMutation {
  public static let operationName: String = "removeComicToFolder"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation removeComicToFolder($comicId: ID!, $folderId: ID!) { removeComicToFolder(comicId: $comicId, folderId: $folderId) }"#
    ))

  public var comicId: ID
  public var folderId: ID

  public init(
    comicId: ID,
    folderId: ID
  ) {
    self.comicId = comicId
    self.folderId = folderId
  }

  public var __variables: Variables? { [
    "comicId": comicId,
    "folderId": folderId
  ] }

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("removeComicToFolder", Bool.self, arguments: [
        "comicId": .variable("comicId"),
        "folderId": .variable("folderId")
      ]),
    ] }

    public var removeComicToFolder: Bool { __data["removeComicToFolder"] }
  }
}