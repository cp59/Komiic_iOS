//
//  KomiicApp.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/28.
//

import SwiftUI
import KomiicAPI

@main
struct KomiicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(AppEnvironment())
        }
    }
}
public extension View {
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(ViewFirstAppearModifier(perform: action))
    }
}

class AppEnvironment: ObservableObject {
    @Published var isLogin = false
    @Published var token = ""
}

struct ViewFirstAppearModifier: ViewModifier {
    @State private var didAppearBefore = false
    private let action: () -> Void

    init(perform action: @escaping () -> Void) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            guard !didAppearBefore else { return }
            didAppearBefore = true
            action()
        }
    }
}
extension ComicFrag: Identifiable {
}

struct ExitButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(white: colorScheme == .dark ? 0.19 : 0.93))
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .font(Font.body.weight(.bold))
                .scaleEffect(0.416)
                .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

enum LoadState {
    case loading
    case loaded
    case failed
    case end
    case loadingMore
    case checkingAccount
}

enum ReaderLoadState {
    case initializing
    case fetchingImages
    case reveal
    case failed
}

enum ListType {
    case recentUpdate
    case monthHotComic
    case hotComic
    case folderComic
    case allComics
    case authorComics
    case categoryComics
}
