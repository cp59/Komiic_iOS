// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AccountQuery: GraphQLQuery {
  public static let operationName: String = "accountQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query accountQuery { account { id email nickname dateCreated favoriteComicIds profileText profileTextColor profileBackgroundColor totalDonateAmount monthDonateAmount profileImageUrl nextChapterMode __typename } }"#
    ))

  public init() {}

  public struct Data: KomiicAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("account", Account.self),
    ] }

    public var account: Account { __data["account"] }

    /// Account
    ///
    /// Parent Type: `Account`
    public struct Account: KomiicAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { KomiicAPI.Objects.Account }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", KomiicAPI.ID.self),
        .field("email", String.self),
        .field("nickname", String.self),
        .field("dateCreated", KomiicAPI.Time?.self),
        .field("favoriteComicIds", [KomiicAPI.ID?].self),
        .field("profileText", String?.self),
        .field("profileTextColor", String?.self),
        .field("profileBackgroundColor", String?.self),
        .field("totalDonateAmount", Int.self),
        .field("monthDonateAmount", Int.self),
        .field("profileImageUrl", String?.self),
        .field("nextChapterMode", String?.self),
      ] }

      public var id: KomiicAPI.ID { __data["id"] }
      public var email: String { __data["email"] }
      public var nickname: String { __data["nickname"] }
      public var dateCreated: KomiicAPI.Time? { __data["dateCreated"] }
      public var favoriteComicIds: [KomiicAPI.ID?] { __data["favoriteComicIds"] }
      public var profileText: String? { __data["profileText"] }
      public var profileTextColor: String? { __data["profileTextColor"] }
      public var profileBackgroundColor: String? { __data["profileBackgroundColor"] }
      public var totalDonateAmount: Int { __data["totalDonateAmount"] }
      public var monthDonateAmount: Int { __data["monthDonateAmount"] }
      public var profileImageUrl: String? { __data["profileImageUrl"] }
      public var nextChapterMode: String? { __data["nextChapterMode"] }
    }
  }
}