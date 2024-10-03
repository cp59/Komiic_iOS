// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == KomiicAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == KomiicAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == KomiicAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == KomiicAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Query": return KomiicAPI.Objects.Query
    case "Comic": return KomiicAPI.Objects.Comic
    case "Author": return KomiicAPI.Objects.Author
    case "Category": return KomiicAPI.Objects.Category
    case "ImageLimit": return KomiicAPI.Objects.ImageLimit
    case "Mutation": return KomiicAPI.Objects.Mutation
    case "Image": return KomiicAPI.Objects.Image
    case "Account": return KomiicAPI.Objects.Account
    case "FolderComicIds": return KomiicAPI.Objects.FolderComicIds
    case "FavoriteV2": return KomiicAPI.Objects.FavoriteV2
    case "Folder": return KomiicAPI.Objects.Folder
    case "ComicLastReadObj": return KomiicAPI.Objects.ComicLastReadObj
    case "ComicLastRead": return KomiicAPI.Objects.ComicLastRead
    case "Chapter": return KomiicAPI.Objects.Chapter
    case "ReadComicHistory": return KomiicAPI.Objects.ReadComicHistory
    case "ReadChapterHistory": return KomiicAPI.Objects.ReadChapterHistory
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
