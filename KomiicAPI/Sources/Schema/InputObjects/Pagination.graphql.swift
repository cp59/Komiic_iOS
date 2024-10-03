// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct Pagination: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    limit: Int,
    offset: Int,
    orderBy: GraphQLEnum<OrderBy>,
    asc: Bool,
    status: GraphQLNullable<String> = nil,
    readProgress: GraphQLNullable<GraphQLEnum<ReadProgressType>> = nil
  ) {
    __data = InputDict([
      "limit": limit,
      "offset": offset,
      "orderBy": orderBy,
      "asc": asc,
      "status": status,
      "readProgress": readProgress
    ])
  }

  public var limit: Int {
    get { __data["limit"] }
    set { __data["limit"] = newValue }
  }

  public var offset: Int {
    get { __data["offset"] }
    set { __data["offset"] = newValue }
  }

  public var orderBy: GraphQLEnum<OrderBy> {
    get { __data["orderBy"] }
    set { __data["orderBy"] = newValue }
  }

  public var asc: Bool {
    get { __data["asc"] }
    set { __data["asc"] = newValue }
  }

  public var status: GraphQLNullable<String> {
    get { __data["status"] }
    set { __data["status"] = newValue }
  }

  public var readProgress: GraphQLNullable<GraphQLEnum<ReadProgressType>> {
    get { __data["readProgress"] }
    set { __data["readProgress"] = newValue }
  }
}
