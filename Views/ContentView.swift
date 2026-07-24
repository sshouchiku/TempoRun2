import SwiftUI

struct ContentView: View {

    @StateObject
    private var locationManager =
        LocationManager()

    @StateObject
    private var favoritesManager =
        FavoritesManager()

    @StateObject
    private var shuffleManager =
        ShuffleManager()

    @StateObject
    private var lastPlayedManager =
        LastPlayedManager()

    @StateObject
    private var historyManager =
        HistoryManager()


    // =====================================
    // 現在の動画
    // =====================================

    @State
    private var selectedVideo:
        YouTubeVideo?

    @State
    private var currentVideoID:
        String = "2I25AFSBm2g"


    // =====================================
    // 再生
    // =====================================

    @State
    private var playbackRate:
        Double = 0.6

    @State
    private var manualPlaybackRate:
        Double = 1.0

    @State
    private var shouldAutoplay:
        Bool = false


    // =====================================
    // ランニング
    // =====================================

    @State
    private var targetSpeed:
        Double = 10.0

    @State
    private var runningMode:
        RunningMode = .normal


    // =====================================
    // タブ
    // =====================================

    @State
    private var selectedTab:
        AppTab = .home


    var body: some View {

        VStack(
            spacing: 0
        ) {

            // =====================================
            // 常駐YouTubeプレイヤー
            // =====================================

            persistentPlayer


            // =====================================
            // タブ
            // =====================================

            TabView(
                selection:
                    $selectedTab
            ) {

                HomeView(
                    locationManager:
                        locationManager,
                    favoritesManager:
                        favoritesManager,
                    shuffleManager:
                        shuffleManager,
                    lastPlayedManager:
                        lastPlayedManager,
                    selectedVideo:
                        $selectedVideo,
                    currentVideoID:
                        $currentVideoID,
                    playbackRate:
                        $playbackRate,
                    manualPlaybackRate:
                        $manualPlaybackRate,
                    targetSpeed:
                        $targetSpeed,
                    runningMode:
                        $runningMode,
                    shouldAutoplay:
                        $shouldAutoplay,
                    onNextTrack: {

                        playNextTrack()
                    }
                )
                .tag(
                    AppTab.home
                )
                .tabItem {

                    Label(
                        "ホーム",
                        systemImage:
                            "house.fill"
                    )
                }


                SearchView(
                    selectedVideo:
                        $selectedVideo,
                    currentVideoID:
                        $currentVideoID,
                    favoritesManager:
                        favoritesManager,
                    shuffleManager:
                        shuffleManager,
                    shouldAutoplay:
                        $shouldAutoplay,
                    selectedTab:
                        $selectedTab
                )
                .tag(
                    AppTab.search
                )
                .tabItem {

                    Label(
                        "検索",
                        systemImage:
                            "magnifyingglass"
                    )
                }


                LibraryView(
                    selectedVideo:
                        $selectedVideo,
                    currentVideoID:
                        $currentVideoID,
                    favoritesManager:
                        favoritesManager,
                    shuffleManager:
                        shuffleManager,
                    historyManager:
                        historyManager,
                    shouldAutoplay:
                        $shouldAutoplay,
                    selectedTab:
                        $selectedTab
                )
                .tag(
                    AppTab.library
                )
                .tabItem {

                    Label(
                        "ライブラリ",
                        systemImage:
                            "music.note.list"
                    )
                }
            }
            .tint(
                MelonomeTheme.accent
            )
        }
        .background(
            MelonomeTheme.background
        )
        .preferredColorScheme(
            .dark
        )

        // =====================================
        // 曲が変わったら保存＋履歴
        // =====================================

        .onChange(
            of: selectedVideo
        ) { _, newVideo in

            guard let video =
                    newVideo
            else {
                return
            }

            lastPlayedManager.save(
                video
            )

            historyManager.add(
                video
            )
        }
    }


    // =====================================
    // 常駐プレイヤー
    // =====================================

    private var persistentPlayer:
        some View {

        VStack(
            spacing: 0
        ) {

            HStack(
                alignment: .center,
                spacing: 10
            ) {

                // =====================================
                // 唯一のYouTubePlayer
                // =====================================

                YouTubePlayerView(
                    videoID:
                        currentVideoID,
                    playbackRate:
                        $playbackRate,
                    autoplay:
                        shouldAutoplay,
                    onVideoEnded: {

                        playNextTrack()
                    }
                )
                .frame(
                    maxWidth:
                        selectedTab == .home
                        ? .infinity
                        : 120,
                    minHeight:
                        selectedTab == .home
                        ? nil
                        : 68,
                    maxHeight:
                        selectedTab == .home
                        ? nil
                        : 68
                )
                .aspectRatio(
                    selectedTab == .home
                    ? 16 / 9
                    : nil,
                    contentMode:
                        .fit
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius:
                            selectedTab == .home
                            ? 20
                            : 10
                    )
                )


                // =====================================
                // Home以外
                // =====================================

                if selectedTab
                    != .home {

                    if let video =
                        selectedVideo {

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(
                                video.title
                            )
                            .font(
                                .subheadline
                            )
                            .fontWeight(
                                .semibold
                            )
                            .lineLimit(1)


                            Text(
                                video.channelTitle
                            )
                            .font(
                                .caption
                            )
                            .foregroundStyle(
                                .secondary
                            )
                            .lineLimit(1)


                            if shuffleManager
                                .isShuffleEnabled {

                                HStack(
                                    spacing: 4
                                ) {

                                    Image(
                                        systemName:
                                            "shuffle"
                                    )

                                    Text(
                                        "シャッフル再生中"
                                    )
                                }
                                .font(
                                    .caption2
                                )
                                .foregroundStyle(
                                    MelonomeTheme
                                        .accent
                                )
                            }
                        }
                    }


                    Spacer()


                    Button {

                        selectedTab =
                            .home

                    } label: {

                        Image(
                            systemName:
                                "chevron.up.circle.fill"
                        )
                        .font(
                            .title2
                        )
                        .foregroundStyle(
                            MelonomeTheme
                                .accent
                        )
                    }
                    .buttonStyle(
                        .plain
                    )
                }
            }
            .padding(
                .horizontal,
                selectedTab == .home
                ? 18
                : 10
            )
            .padding(
                .top,
                8
            )
            .padding(
                .bottom,
                selectedTab == .home
                ? 10
                : 8
            )
        }
        .background(
            MelonomeTheme.background
        )
    }


    // =====================================
    // 次の曲
    // =====================================

    private func playNextTrack() {

        // -------------------------------------
        // シャッフル再生中
        // -------------------------------------

        if shuffleManager
            .isShuffleEnabled {

            guard let video =
                    shuffleManager
                        .next(
                            favorites:
                                favoritesManager
                                    .favorites
                        )
            else {
                return
            }

            shouldAutoplay =
                true

            selectedVideo =
                video

            currentVideoID =
                video.id

            return
        }


        // -------------------------------------
        // 通常時
        //
        // お気に入りから別の曲を選ぶ
        // -------------------------------------

        let favorites =
            favoritesManager
                .favorites


        guard !favorites.isEmpty else {
            return
        }


        var candidates =
            favorites


        // 2曲以上あるなら
        // 現在の曲を除外

        if favorites.count > 1 {

            candidates.removeAll {

                $0.id ==
                    selectedVideo?.id
            }
        }


        guard let video =
                candidates
                    .randomElement()
        else {
            return
        }


        shouldAutoplay =
            true

        selectedVideo =
            video

        currentVideoID =
            video.id
    }
}


// =====================================
// タブ
// =====================================

enum AppTab:
    Hashable {

    case home
    case search
    case library
}


// =====================================
// 走行モード
// =====================================

enum RunningMode:
    String,
    CaseIterable,
    Identifiable {

    case normal =
        "ノーマル"

    case boost =
        "ブースト"

    case manual =
        "マニュアル"


    var id: String {

        rawValue
    }


    var description: String {

        switch self {

        case .normal:

            return
                "目標速度に達すると通常の速さで再生"

        case .boost:

            return
                "目標速度を超えるほど音楽も加速"

        case .manual:

            return
                "再生速度を自分で調整"
        }
    }
}


// =====================================
// テーマ
// =====================================

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
