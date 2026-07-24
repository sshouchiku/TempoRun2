import SwiftUI

struct ContentView: View {

    @StateObject
    private var locationManager = LocationManager()

    @StateObject
    private var favoritesManager = FavoritesManager()

    @State
    private var selectedVideo: YouTubeVideo?

    @State
    private var currentVideoID: String = "2I25AFSBm2g"

    @State
    private var playbackRate: Double = 0.6

    @State
    private var targetSpeed: Double = 10.0

    @State
    private var runningMode: RunningMode = .normal

    @State
    private var selectedTab: AppTab = .home


    var body: some View {

        TabView(selection: $selectedTab) {

            HomeView(
                locationManager: locationManager,
                favoritesManager: favoritesManager,
                selectedVideo: $selectedVideo,
                currentVideoID: $currentVideoID,
                playbackRate: $playbackRate,
                targetSpeed: $targetSpeed,
                runningMode: $runningMode
            )
            .tag(AppTab.home)
            .tabItem {

                Label(
                    "ホーム",
                    systemImage: "house.fill"
                )
            }


            SearchView(
                selectedVideo: $selectedVideo,
                currentVideoID: $currentVideoID,
                favoritesManager: favoritesManager,
                selectedTab: $selectedTab
            )
            .tag(AppTab.search)
            .tabItem {

                Label(
                    "検索",
                    systemImage: "magnifyingglass"
                )
            }


            LibraryView(
                selectedVideo: $selectedVideo,
                currentVideoID: $currentVideoID,
                favoritesManager: favoritesManager,
                selectedTab: $selectedTab
            )
            .tag(AppTab.library)
            .tabItem {

                Label(
                    "ライブラリ",
                    systemImage: "music.note.list"
                )
            }
        }
        .tint(MelonomeTheme.accent)
        .preferredColorScheme(.dark)
    }
}


// MARK: - タブ

enum AppTab: Hashable {

    case home
    case search
    case library
}


// MARK: - 走行モード

enum RunningMode:
    String,
    CaseIterable,
    Identifiable {

    case normal = "ノーマル"
    case boost = "ブースト"

    var id: String {
        rawValue
    }

    var description: String {

        switch self {

        case .normal:
            return "目標速度に達すると通常の速さで再生"

        case .boost:
            return "目標速度を超えるほど音楽も加速"
        }
    }
}


// MARK: - Melonome Theme

enum MelonomeTheme {

    static let background =
        Color(
            red: 0.035,
            green: 0.04,
            blue: 0.045
        )

    static let card =
        Color(
            red: 0.085,
            green: 0.09,
            blue: 0.10
        )

    static let cardLight =
        Color(
            red: 0.12,
            green: 0.125,
            blue: 0.135
        )

    static let accent =
        Color(
            red: 0.68,
            green: 1.0,
            blue: 0.26
        )
}


#Preview {

    ContentView()
}
