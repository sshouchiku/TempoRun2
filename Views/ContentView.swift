import SwiftUI

struct ContentView: View {

    // =====================================
    // ランニングモード
    // =====================================

    enum RunningMode: String, CaseIterable, Identifiable {

        case normal = "Normal"
        case boost = "Boost"

        var id: String {
            rawValue
        }

        var description: String {

            switch self {

            case .normal:
                return "目標速度に達すると1.0x"

            case .boost:
                return "目標速度を超えると1.0xより速くなる"
            }
        }
    }


    // =====================================
    // Managers
    // =====================================

    @StateObject
    private var locationManager =
        LocationManager()

    @StateObject
    private var favoritesManager =
        FavoritesManager()

    private let youtubeService =
        YouTubeSearchService()


    // =====================================
    // ランニング設定
    // =====================================

    @State
    private var targetSpeed: Double = 10.0

    @State
    private var runningMode:
        RunningMode = .normal

    @State
    private var playbackRate:
        Double = 0.6


    // =====================================
    // YouTube
    // =====================================

    private let defaultVideoID =
        "2I25AFSBm2g"

    @State
    private var selectedVideo:
        YouTubeVideo?

    @State
    private var currentVideoID:
        String = "2I25AFSBm2g"


    // =====================================
    // URL入力
    // =====================================

    @State
    private var youtubeURL:
        String = ""

    @State
    private var urlError:
        String?

    @State
    private var isLoadingVideo:
        Bool = false


    // =====================================
    // 再生速度変更制御
    // =====================================

    @State
    private var lastAppliedRate:
        Double = 0.6

    @State
    private var lastRateChangeTime:
        Date = .distantPast


    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                // =====================================
                // タイトル
                // =====================================

                Text("TempoRun 2")
                    .font(.largeTitle)
                    .fontWeight(.bold)


                // =====================================
                // YouTube検索
                // =====================================

                YouTubeSearchView(
                    selectedVideo:
                        $selectedVideo,
                    favoritesManager:
                        favoritesManager
                )


                // =====================================
                // お気に入り
                // =====================================

                if !favoritesManager
                    .favorites
                    .isEmpty {

                    Divider()

                    VStack(
                        alignment: .leading,
                        spacing: 12
                    ) {

                        HStack {

                            Image(
                                systemName:
                                    "star.fill"
                            )
                            .foregroundStyle(
                                .yellow
                            )

                            Text("お気に入り")
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        ScrollView(
                            .horizontal,
                            showsIndicators: false
                        ) {

                            HStack(
                                spacing: 12
                            ) {

                                ForEach(
                                    favoritesManager
                                        .favorites
                                ) { video in

                                    favoriteCard(
                                        video
                                    )
                                }
                            }
                        }
                    }
                }


                Divider()


                // =====================================
                // 現在の動画情報
                // =====================================

                if let selectedVideo {

                    HStack(
                        spacing: 12
                    ) {

                        AsyncImage(
                            url: URL(
                                string:
                                    selectedVideo
                                        .thumbnailURL
                            )
                        ) { image in

                            image
                                .resizable()
                                .scaledToFill()

                        } placeholder: {

                            Rectangle()
                                .fill(
                                    Color.gray
                                        .opacity(
                                            0.2
                                        )
                                )
                        }
                        .frame(
                            width: 110,
                            height: 62
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 8
                            )
                        )


                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("現在の動画")
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )

                            Text(
                                selectedVideo.title
                            )
                            .font(.headline)
                            .lineLimit(2)

                            Text(
                                selectedVideo.channelTitle
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                        }

                        Spacer()


                        // 現在の動画をお気に入り

                        Button {

                            favoritesManager
                                .toggleFavorite(
                                    selectedVideo
                                )

                        } label: {

                            Image(
                                systemName:
                                    favoritesManager
                                    .isFavorite(
                                        selectedVideo
                                    )
                                    ? "star.fill"
                                    : "star"
                            )
                            .font(.title)
                            .foregroundStyle(
                                favoritesManager
                                .isFavorite(
                                    selectedVideo
                                )
                                ? .yellow
                                : .secondary
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background {

                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .fill(
                            Color.blue
                                .opacity(
                                    0.07
                                )
                        )
                    }

                } else if isLoadingVideo {

                    HStack {

                        ProgressView()

                        Text(
                            "動画情報を取得中..."
                        )
                        .font(.caption)
                    }
                }


                // =====================================
                // YouTube Player
                // =====================================

                YouTubePlayerView(
                    videoID:
                        currentVideoID,
                    playbackRate:
                        $playbackRate
                )
                .id(
                    currentVideoID
                )
                .aspectRatio(
                    16 / 9,
                    contentMode: .fit
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                )


                // =====================================
                // URLから読み込み
                // =====================================

                DisclosureGroup(
                    "URLから動画を読み込む"
                ) {

                    VStack(
                        spacing: 10
                    ) {

                        TextField(
                            "YouTube URLを貼り付け",
                            text:
                                $youtubeURL
                        )
                        .textFieldStyle(
                            .roundedBorder
                        )
                        .textInputAutocapitalization(
                            .never
                        )
                        .autocorrectionDisabled()

                        Button(
                            "動画を読み込む"
                        ) {

                            loadYouTubeVideo()
                        }
                        .buttonStyle(
                            .bordered
                        )

                        if let urlError {

                            Text(
                                urlError
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .red
                            )
                        }
                    }
                    .padding(.top, 10)
                }


                Divider()


                // =====================================
                // 現在速度
                // =====================================

                VStack(
                    spacing: 5
                ) {

                    Text(
                        "Current Speed"
                    )
                    .font(.headline)

                    Text(
                        String(
                            format:
                                "%.1f km/h",
                            locationManager.speed
                        )
                    )
                    .font(
                        .system(
                            size: 38,
                            weight: .bold
                        )
                    )
                }


                Divider()


                // =====================================
                // 目標速度
                // =====================================

                VStack(
                    spacing: 10
                ) {

                    Text(
                        "Target Speed"
                    )
                    .font(.headline)

                    Text(
                        String(
                            format:
                                "%.1f km/h",
                            targetSpeed
                        )
                    )
                    .font(.title2)

                    Slider(
                        value:
                            $targetSpeed,
                        in:
                            5...20,
                        step:
                            0.5
                    )
                }


                Divider()


                // =====================================
                // ランニングモード
                // =====================================

                VStack(
                    spacing: 12
                ) {

                    Text("Running Mode")
                        .font(.headline)

                    Picker(
                        "Running Mode",
                        selection:
                            $runningMode
                    ) {

                        ForEach(
                            RunningMode.allCases
                        ) { mode in

                            Text(
                                mode.rawValue
                            )
                            .tag(mode)
                        }
                    }
                    .pickerStyle(
                        .segmented
                    )

                    Text(
                        runningMode.description
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )

                    if runningMode == .boost {

                        Text(
                            "目標を超えるほど音楽も加速"
                        )
                        .font(.caption)
                        .fontWeight(
                            .semibold
                        )
                    }
                }


                Divider()


                // =====================================
                // Playback Speed
                // =====================================

                VStack(
                    spacing: 5
                ) {

                    Text(
                        "Playback Speed"
                    )
                    .font(.headline)

                    Text(
                        String(
                            format:
                                "%.2fx",
                            playbackRate
                        )
                    )
                    .font(.title)
                    .fontWeight(.bold)


                    // Boost中に1倍を超えたら表示

                    if playbackRate > 1.0 {

                        HStack {

                            Image(
                                systemName:
                                    "bolt.fill"
                            )

                            Text("BOOST")
                                .fontWeight(
                                    .bold
                                )
                        }
                        .font(.caption)
                    }
                }
            }
            .padding()
        }


        // =====================================
        // 検索・お気に入りで動画選択
        // =====================================

        .onChange(
            of: selectedVideo
        ) { _, newVideo in

            guard let newVideo else {
                return
            }

            currentVideoID =
                newVideo.id
        }


        // =====================================
        // GPS速度変更
        // =====================================

        .onChange(
            of:
                locationManager.speed
        ) { _, newSpeed in

            updatePlaybackRate(
                currentSpeed:
                    newSpeed
            )
        }


        // =====================================
        // 目標速度変更
        // =====================================

        .onChange(
            of:
                targetSpeed
        ) { _, _ in

            updatePlaybackRate(
                currentSpeed:
                    locationManager.speed,
                force:
                    true
            )
        }


        // =====================================
        // モード変更
        // =====================================

        .onChange(
            of:
                runningMode
        ) { _, _ in

            updatePlaybackRate(
                currentSpeed:
                    locationManager.speed,
                force:
                    true
            )
        }


        // =====================================
        // 起動時
        // =====================================

        .task {

            await loadVideoInformation(
                videoID:
                    defaultVideoID
            )
        }


        .onAppear {

            updatePlaybackRate(
                currentSpeed:
                    locationManager.speed,
                force:
                    true
            )
        }
    }


    // =====================================
    // お気に入りカード
    // =====================================

    @ViewBuilder
    private func favoriteCard(
        _ video: YouTubeVideo
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Button {

                selectedVideo =
                    video

            } label: {

                AsyncImage(
                    url: URL(
                        string:
                            video.thumbnailURL
                    )
                ) { image in

                    image
                        .resizable()
                        .scaledToFill()

                } placeholder: {

                    Rectangle()
                        .fill(
                            Color.gray
                                .opacity(
                                    0.2
                                )
                        )
                }
                .frame(
                    width: 150,
                    height: 84
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10
                    )
                )
            }
            .buttonStyle(.plain)

            Text(
                video.title
            )
            .font(.caption)
            .fontWeight(
                .semibold
            )
            .lineLimit(2)
            .frame(
                width: 150,
                alignment: .leading
            )

            HStack {

                Text(
                    video.channelTitle
                )
                .font(.caption2)
                .foregroundStyle(
                    .secondary
                )
                .lineLimit(1)

                Spacer()

                Button {

                    favoritesManager
                        .toggleFavorite(
                            video
                        )

                } label: {

                    Image(
                        systemName:
                            "star.fill"
                    )
                    .foregroundStyle(
                        .yellow
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(
                width: 150
            )
        }
    }


    // =====================================
    // Video IDから動画情報取得
    // =====================================

    @MainActor
    private func loadVideoInformation(
        videoID: String
    ) async {

        isLoadingVideo =
            true

        do {

            let video =
                try await youtubeService
                    .fetchVideo(
                        videoID:
                            videoID
                    )

            selectedVideo =
                video

            currentVideoID =
                video.id

        } catch {

            print(
                "動画情報取得失敗:",
                error
            )

            currentVideoID =
                videoID
        }

        isLoadingVideo =
            false
    }


    // =====================================
    // URL読み込み
    // =====================================

    private func loadYouTubeVideo() {

        guard let newVideoID =
                extractYouTubeVideoID(
                    from:
                        youtubeURL
                )
        else {

            urlError =
                "有効なYouTube URLを入力してください"

            return
        }

        urlError =
            nil

        currentVideoID =
            newVideoID

        Task {

            await loadVideoInformation(
                videoID:
                    newVideoID
            )
        }
    }


    private func extractYouTubeVideoID(
        from urlString:
            String
    ) -> String? {

        let trimmed =
            urlString
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        guard
            let url =
                URL(
                    string:
                        trimmed
                ),
            let host =
                url.host?
                    .lowercased()
        else {

            return nil
        }

        // youtu.be

        if host ==
            "youtu.be"
            || host ==
            "www.youtu.be" {

            return url
                .pathComponents
                .filter {
                    $0 != "/"
                }
                .first
        }


        // youtube.com系

        if host ==
            "youtube.com"
            || host ==
            "www.youtube.com"
            || host ==
            "m.youtube.com"
            || host ==
            "music.youtube.com" {

            // watch?v=

            if url.path ==
                "/watch" {

                let components =
                    URLComponents(
                        url: url,
                        resolvingAgainstBaseURL:
                            false
                    )

                return components?
                    .queryItems?
                    .first(
                        where: {
                            $0.name ==
                                "v"
                        }
                    )?
                    .value
            }


            // shorts

            if url.path
                .hasPrefix(
                    "/shorts/"
                ) {

                let parts =
                    url.pathComponents

                if let index =
                    parts.firstIndex(
                        of:
                            "shorts"
                    ),
                   parts.indices
                    .contains(
                        index + 1
                    ) {

                    return parts[
                        index + 1
                    ]
                }
            }


            // embed

            if url.path
                .hasPrefix(
                    "/embed/"
                ) {

                let parts =
                    url.pathComponents

                if let index =
                    parts.firstIndex(
                        of:
                            "embed"
                    ),
                   parts.indices
                    .contains(
                        index + 1
                    ) {

                    return parts[
                        index + 1
                    ]
                }
            }
        }

        return nil
    }


    // =====================================
    // GPS速度 → Playback速度
    // =====================================

    private func updatePlaybackRate(
        currentSpeed: Double,
        force: Bool = false
    ) {

        // 実際の最低速度
        let minimumRate =
            0.6

        // 元々の計算基準
        //
        // 0.4 → 1.0の傾きは
        // そのまま維持する
        let originalMinimumRate =
            0.4

        let speedRange =
            5.0

        let minimumSpeed =
            targetSpeed
            - speedRange

        let calculatedRate:
            Double


        // =====================================
        // 目標速度以上
        // =====================================

        if currentSpeed
            >= targetSpeed {

            switch runningMode {

            // -------------------------
            // Normal
            //
            // 目標以上は1.0固定
            // -------------------------

            case .normal:

                calculatedRate =
                    1.0


            // -------------------------
            // Boost
            //
            // 目標以上も同じ傾きで
            // 再生速度を上げる
            // -------------------------

            case .boost:

                let excessSpeed =
                    currentSpeed
                    - targetSpeed

                // 元の傾き
                //
                // (1.0 - 0.4) / 5
                // = 0.12 / km/h

                let rateIncreasePerKm =
                    (
                        1.0
                        - originalMinimumRate
                    )
                    / speedRange

                calculatedRate =
                    1.0
                    + excessSpeed
                    * rateIncreasePerKm
            }
        }


        // =====================================
        // 目標 - 5km/h以下
        // =====================================

        else if currentSpeed
            <= minimumSpeed {

            calculatedRate =
                originalMinimumRate
        }


        // =====================================
        // 目標未満
        // =====================================

        else {

            let progress =
                (
                    currentSpeed
                    - minimumSpeed
                )
                / speedRange

            calculatedRate =
                originalMinimumRate
                + (
                    1.0
                    - originalMinimumRate
                )
                * progress
        }


        // =====================================
        // 最小・最大値
        // =====================================

        let maximumRate:

            Double =
                runningMode
                == .boost
                ? 1.4
                : 1.0

        let limitedRate =
            min(
                max(
                    calculatedRate,
                    minimumRate
                ),
                maximumRate
            )


        // =====================================
        // Normalで目標到達
        //
        // 0.96などで止まらず
        // 必ず1.0にする
        // =====================================

        if runningMode
            == .normal
            && currentSpeed
            >= targetSpeed {

            if abs(
                lastAppliedRate
                - 1.0
            ) > 0.001 {

                playbackRate =
                    1.0

                lastAppliedRate =
                    1.0

                lastRateChangeTime =
                    Date()
            }

            return
        }


        // =====================================
        // Boostでも
        // 目標速度に到達した瞬間は
        // 1.0を確実に通るようにする
        // =====================================

        if runningMode
            == .boost
            && currentSpeed
            >= targetSpeed
            && lastAppliedRate
                < 1.0
            && limitedRate
                < 1.05 {

            playbackRate =
                1.0

            lastAppliedRate =
                1.0

            lastRateChangeTime =
                Date()

            return
        }


        // =====================================
        // 変更頻度制限
        //
        // YouTubeの音切れ対策
        // =====================================

        if !force {

            let minimumRateDifference =
                0.05

            if abs(
                limitedRate
                - lastAppliedRate
            ) < minimumRateDifference {

                return
            }


            let minimumInterval =
                1.0

            let elapsedTime =
                Date()
                .timeIntervalSince(
                    lastRateChangeTime
                )

            if elapsedTime
                < minimumInterval {

                return
            }
        }


        // =====================================
        // 反映
        // =====================================

        playbackRate =
            limitedRate

        lastAppliedRate =
            limitedRate

        lastRateChangeTime =
            Date()
    }
}


#Preview {

    ContentView()
}
