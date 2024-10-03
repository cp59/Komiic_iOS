// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AllCategoryQuery: GraphQLQuery {
  public static let operationName: String = "allCategory"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query allCategory { allCategory { __typename id name } }"#
    ))

  public init() {}

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("allCategory", [AllCategory?].self),
    ] }

    public var allCategory: [AllCategory?] { __data["allCategory"] }

    /// AllCategory
    ///
    /// Parent Type: `Category`
    public struct AllCategory: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Category }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KomiicAPI.ID.self),
        .field("name", String.self),
      ] }

      public var id: KomiicAPI.ID { __data["id"] }
      public var name: String { __data["name"] }
    }
  }
}