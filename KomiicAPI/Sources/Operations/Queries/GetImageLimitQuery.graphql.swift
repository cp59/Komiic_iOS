// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetImageLimitQuery: GraphQLQuery {
  public static let operationName: String = "getImageLimit"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query getImageLimit { getImageLimit { __typename limit usage resetInSeconds } }"#
    ))

  public init() {}

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getImageLimit", GetImageLimit.self),
    ] }

    public var getImageLimit: GetImageLimit { __data["getImageLimit"] }

    /// GetImageLimit
    ///
    /// Parent Type: `ImageLimit`
    public struct GetImageLimit: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.ImageLimit }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("limit", Int.self),
        .field("usage", Int.self),
        .field("resetInSeconds", String.self),
      ] }

      public var limit: Int { __data["limit"] }
      public var usage: Int { __data["usage"] }
      public var resetInSeconds: String { __data["resetInSeconds"] }
    }
  }
}