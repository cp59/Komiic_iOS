// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ComicInAccountFoldersQuery: GraphQLQuery {
  public static let operationName: String = "comicInAccountFolders"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query comicInAccountFolders($comicId: ID!) { comicInAccountFolders(comicId: $comicId) }"#
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
      .field("comicInAccountFolders", [KomiicAPI.ID?].self, arguments: ["comicId": .variable("comicId")]),
    ] }

    public var comicInAccountFolders: [KomiicAPI.ID?] { __data["comicInAccountFolders"] }
  }
}