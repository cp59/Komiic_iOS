// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct FolderFrag: KomiicAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment FolderFrag on Folder { __typename id key name views comicCount dateCreated dateUpdated }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Folder }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", KomiicAPI.ID.self),
    .field("key", String.self),
    .field("name", String.self),
    .field("views", Int?.self),
    .field("comicCount", Int.self),
    .field("dateCreated", KomiicAPI.Time?.self),
    .field("dateUpdated", KomiicAPI.Time?.self),
  ] }

  public var id: KomiicAPI.ID { __data["id"] }
  public var key: String { __data["key"] }
  public var name: String { __data["name"] }
  public var views: Int? { __data["views"] }
  public var comicCount: Int { __data["comicCount"] }
  public var dateCreated: KomiicAPI.Time? { __data["dateCreated"] }
  public var dateUpdated: KomiicAPI.Time? { __data["dateUpdated"] }
}
