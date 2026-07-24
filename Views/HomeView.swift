import SwiftUI

struct HomeView: View {

    @ObservedObject
    var locationManager:
        LocationManager

    @ObservedObject
    var favoritesManager:
        FavoritesManager

    @ObservedObject
    var shuffleManager:
        ShuffleManager

    @ObservedObject
    var lastPlayedManager:
        LastPlayedManager


    @Binding
    var selectedVideo:
        YouTubeVideo?

    @Binding
    var currentVideoID:
        String

    @Binding
    var playbackRate:
        Double

    @Binding
    var manualPlaybackRate:
        Double

    @Binding
    var targetSpeed:
        Double

    @Binding
    var runningMode:
        RunningMode

    @Binding
    var shouldAutoplay:
        Bool


    let onNextTrack:
        () -> Void


    private let youtubeService =
        YouTubeSearchService()


    @State
    private var lastAppliedRate:
        Double = 0.6

    @State
    private var lastRateChangeTime:
        Date = .distantPast

    @State
    private var showRunView:
        Bool = false


    var body: some View {

        NavigationStack {

            ZStack {

                MelonomeTheme
                    .background
                    .ignoresSafeArea()


                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 26
                    ) {

                        header

                        currentTrackSection

                        runningSection

                        modeSection

                        startRunningButton

                        favoritesSection
                    }
                    .padding(
                        .horizontal,
                        18
                    )
                    .padding(
                        .bottom,
                        30
                    )
                }
            }
            .toolbar(
                .hidden
            )


            // =====================================
            // ランニング画面
            // =====================================

            .fullScreenCover(
                isPresented:
                    $showRunView
            ) {

                RunView(
                    locationManager:
                        locationManager,
                    selectedVideo:
                        $selectedVideo,
                    playbackRate:
                        $playbackRate,
                    targetSpeed:
                        $targetSpeed,
                    runningMode:
                        $runningMode,
                    onNextTrack:
                        onNextTrack
                )
            }


            // =====================================
            // 初期動画
            // =====================================

            .task {

                if selectedVideo == nil {

                    await loadInitialVideo()
                }
            }


            // =====================================
            // GPS速度
            // =====================================

            .onChange(
                of: locationManager.speed
            ) { _, speed in

                updatePlaybackRate(
                    currentSpeed:
                        speed
                )
            }


            // =====================================
            // 目標速度
            // =====================================

            .onChange(
                of: targetSpeed
            ) { _, _ in

                updatePlaybackRate(
                    currentSpeed:
                        locationManager.speed,
                    force:
                        true
                )
            }


            // =====================================
            // モード
            // =====================================

            .onChange(
                of: runningMode
            ) { _, newMode in

                if newMode == .manual {

                    playbackRate =
                        manualPlaybackRate

                    lastAppliedRate =
                        manualPlaybackRate

                } else {

                    updatePlaybackRate(
                        currentSpeed:
                            locationManager.speed,
                        force:
                            true
                    )
                }
            }


            // =====================================
            // マニュアル速度
            // =====================================

            .onChange(
                of: manualPlaybackRate
            ) { _, newValue in

                guard runningMode
                    == .manual
                else {
                    return
                }

                playbackRate =
                    newValue

                lastAppliedRate =
                    newValue
            }
        }
    }


    // =====================================
    // ヘッダー
    // =====================================

    private var header:
        some View {

        VStack(
            alignment: .leading,
            spacing: 2
        ) {

            Text(
                "Melonome"
            )
            .font(
                .system(
                    size: 36,
                    weight: .black,
                    design: .rounded
                )
            )


            Text(
                "Music follows your pace."
            )
            .font(
                .subheadline
            )
            .foregroundStyle(
                .secondary
            )
        }
        .padding(
            .top,
            8
        )
    }


    // =====================================
    // 現在の曲
    // =====================================

    @ViewBuilder
    private var currentTrackSection:
        some View {

        if let video =
            selectedVideo {

            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                HStack(
                    spacing: 14
                ) {

                    AsyncImage(
                        url:
                            URL(
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
                                MelonomeTheme
                                    .cardLight
                            )
                    }
                    .frame(
                        width: 92,
                        height: 55
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 10
                        )
                    )


                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {

                        Text(
                            video.title
                        )
                        .font(
                            .title3
                        )
                        .fontWeight(
                            .bold
                        )
                        .lineLimit(2)


                        Text(
                            video.channelTitle
                        )
                        .font(
                            .subheadline
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }


                    Spacer()


                    Button {

                        favoritesManager
                            .toggleFavorite(
                                video
                            )

                    } label: {

                        Image(
                            systemName:
                                favoritesManager
                                .isFavorite(
                                    video
                                )
                                ? "star.fill"
                                : "star"
                        )
                        .font(
                            .title2
                        )
                        .foregroundStyle(
                            favoritesManager
                                .isFavorite(
                                    video
                                )
                            ? MelonomeTheme
                                .accent
                            : .secondary
                        )
                        .frame(
                            width: 48,
                            height: 48
                        )
                        .background(
                            MelonomeTheme
                                .card
                        )
                        .clipShape(
                            Circle()
                        )
                    }
                    .buttonStyle(
                        .plain
                    )
                }


                // 次へ

                HStack {

                    if shuffleManager
                        .isShuffleEnabled {

                        HStack(
                            spacing: 5
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
                            .caption
                        )
                        .foregroundStyle(
                            MelonomeTheme
                                .accent
                        )
                    }


                    Spacer()


                    Button {

                        onNextTrack()

                    } label: {

                        HStack {

                            Text(
                                "次へ"
                            )

                            Image(
                                systemName:
                                    "forward.end.fill"
                            )
                        }
                        .fontWeight(
                            .semibold
                        )
                    }
                    .buttonStyle(
                        .bordered
                    )
                    .tint(
                        MelonomeTheme
                            .accent
                    )
                }
            }
        }
    }


    // =====================================
    // ランニング
    // =====================================

    private var runningSection:
        some View {

        VStack(
            spacing: 18
        ) {

            VStack(
                spacing: 2
            ) {

                Text(
                    "現在の速度"
                )
                .font(
                    .caption
                )
                .fontWeight(
                    .bold
                )
                .tracking(
                    1.5
                )
                .foregroundStyle(
                    MelonomeTheme
                        .accent
                )


                HStack(
                    alignment:
                        .firstTextBaseline,
                    spacing: 6
                ) {

                    Text(
                        String(
                            format:
                                "%.1f",
                            locationManager.speed
                        )
                    )
                    .font(
                        .system(
                            size: 72,
                            weight: .black,
                            design: .rounded
                        )
                    )


                    Text(
                        "km/h"
                    )
                    .font(
                        .headline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }


            HStack(
                spacing: 12
            ) {

                metricCard(
                    title:
                        "目標速度",
                    value:
                        String(
                            format:
                                "%.1f",
                            targetSpeed
                        ),
                    unit:
                        "km/h",
                    icon:
                        "scope"
                )


                metricCard(
                    title:
                        "再生速度",
                    value:
                        String(
                            format:
                                "%.2f",
                            playbackRate
                        ),
                    unit:
                        "x",
                    icon:
                        playbackRate > 1
                        ? "bolt.fill"
                        : "waveform"
                )
            }


            if runningMode
                != .manual {

                VStack(
                    spacing: 10
                ) {

                    HStack {

                        Text(
                            "目標速度"
                        )
                        .fontWeight(
                            .semibold
                        )

                        Spacer()

                        Text(
                            String(
                                format:
                                    "%.1f km/h",
                                targetSpeed
                            )
                        )
                        .foregroundStyle(
                            MelonomeTheme
                                .accent
                        )
                        .fontWeight(
                            .bold
                        )
                    }


                    Slider(
                        value:
                            $targetSpeed,
                        in:
                            5...20,
                        step:
                            0.5
                    )
                    .tint(
                        MelonomeTheme
                            .accent
                    )
                }
                .padding(
                    18
                )
                .background(
                    MelonomeTheme
                        .card
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 20
                    )
                )
            }
        }
    }


    // =====================================
    // 走行モード
    // =====================================

    private var modeSection:
        some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "走行モード"
            )
            .font(
                .title3
            )
            .fontWeight(
                .bold
            )


            Picker(
                "走行モード",
                selection:
                    $runningMode
            ) {

                Text(
                    "ノーマル"
                )
                .tag(
                    RunningMode.normal
                )


                Text(
                    "⚡ ブースト"
                )
                .tag(
                    RunningMode.boost
                )


                Text(
                    "マニュアル"
                )
                .tag(
                    RunningMode.manual
                )
            }
            .pickerStyle(
                .segmented
            )


            HStack(
                spacing: 10
            ) {

                Image(
                    systemName:
                        modeIcon
                )
                .foregroundStyle(
                    MelonomeTheme
                        .accent
                )


                Text(
                    runningMode
                        .description
                )
                .font(
                    .subheadline
                )
                .foregroundStyle(
                    .secondary
                )
            }


            if runningMode
                == .manual {

                VStack(
                    spacing: 12
                ) {

                    HStack {

                        Text(
                            "再生速度"
                        )
                        .fontWeight(
                            .semibold
                        )

                        Spacer()

                        Text(
                            String(
                                format:
                                    "%.2fx",
                                manualPlaybackRate
                            )
                        )
                        .foregroundStyle(
                            MelonomeTheme
                                .accent
                        )
                        .fontWeight(
                            .bold
                        )
                    }


                    Slider(
                        value:
                            $manualPlaybackRate,
                        in:
                            0.6...1.4,
                        step:
                            0.01
                    )
                    .tint(
                        MelonomeTheme
                            .accent
                    )


                    HStack {

                        Text("0.6x")

                        Spacer()

                        Text("1.0x")

                        Spacer()

                        Text("1.4x")
                    }
                    .font(
                        .caption2
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
                .padding(
                    18
                )
                .background(
                    MelonomeTheme
                        .card
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 20
                    )
                )
            }
        }
    }


    // =====================================
    // ランニング開始
    // =====================================

    private var startRunningButton:
        some View {

        Button {

            showRunView =
                true

        } label: {

            HStack {

                Image(
                    systemName:
                        "figure.run"
                )
                .font(
                    .title2
                )


                Text(
                    "ランニングを開始"
                )
                .font(
                    .headline
                )


                Spacer()


                Image(
                    systemName:
                        "chevron.right"
                )
            }
            .foregroundStyle(
                .black
            )
            .padding(
                18
            )
            .background(
                MelonomeTheme
                    .accent
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )
        }
        .buttonStyle(
            .plain
        )
    }


    // =====================================
    // モードアイコン
    // =====================================

    private var modeIcon:
        String {

        switch runningMode {

        case .normal:

            return
                "metronome.fill"

        case .boost:

            return
                "bolt.fill"

        case .manual:

            return
                "slider.horizontal.3"
        }
    }


    // =====================================
    // お気に入り
    // =====================================

    @ViewBuilder
    private var favoritesSection:
        some View {

        if !favoritesManager
            .favorites
            .isEmpty {

            VStack(
                alignment: .leading,
                spacing: 14
            ) {

                HStack {

                    Text(
                        "お気に入り"
                    )
                    .font(
                        .title2
                    )
                    .fontWeight(
                        .bold
                    )


                    Spacer()


                    Button {

                        startShuffle()

                    } label: {

                        HStack(
                            spacing: 6
                        ) {

                            Image(
                                systemName:
                                    "shuffle"
                            )

                            Text(
                                "シャッフル再生"
                            )
                        }
                        .font(
                            .subheadline
                        )
                        .fontWeight(
                            .bold
                        )
                        .foregroundStyle(
                            .black
                        )
                        .padding(
                            .horizontal,
                            14
                        )
                        .padding(
                            .vertical,
                            9
                        )
                        .background(
                            MelonomeTheme
                                .accent
                        )
                        .clipShape(
                            Capsule()
                        )
                    }
                    .buttonStyle(
                        .plain
                    )
                }


                ScrollView(
                    .horizontal,
                    showsIndicators:
                        false
                ) {

                    HStack(
                        spacing: 14
                    ) {

                        ForEach(
                            favoritesManager
                                .favorites
                                .prefix(8)
                        ) { video in

                            Button {

                                shuffleManager
                                    .stop()

                                // 選んだら即再生

                                shouldAutoplay =
                                    true

                                selectedVideo =
                                    video

                                currentVideoID =
                                    video.id

                            } label: {

                                VStack(
                                    alignment:
                                        .leading,
                                    spacing: 7
                                ) {

                                    AsyncImage(
                                        url:
                                            URL(
                                                string:
                                                    video
                                                    .thumbnailURL
                                            )
                                    ) { image in

                                        image
                                            .resizable()
                                            .scaledToFill()

                                    } placeholder: {

                                        Rectangle()
                                            .fill(
                                                MelonomeTheme
                                                    .cardLight
                                            )
                                    }
                                    .frame(
                                        width: 165,
                                        height: 95
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 14
                                        )
                                    )


                                    Text(
                                        video.title
                                    )
                                    .font(
                                        .subheadline
                                    )
                                    .fontWeight(
                                        .semibold
                                    )
                                    .lineLimit(2)
                                    .frame(
                                        width: 165,
                                        alignment:
                                            .leading
                                    )


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
                                }
                            }
                            .buttonStyle(
                                .plain
                            )
                        }
                    }
                }
            }
        }
    }


    // =====================================
    // カード
    // =====================================

    private func metricCard(
        title: String,
        value: String,
        unit: String,
        icon: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Image(
                    systemName:
                        icon
                )
                .foregroundStyle(
                    MelonomeTheme
                        .accent
                )

                Text(
                    title
                )
                .font(
                    .caption
                )
                .fontWeight(
                    .bold
                )
                .foregroundStyle(
                    .secondary
                )
            }


            HStack(
                alignment:
                    .firstTextBaseline,
                spacing: 4
            ) {

                Text(
                    value
                )
                .font(
                    .system(
                        size: 30,
                        weight: .bold,
                        design: .rounded
                    )
                )

                Text(
                    unit
                )
                .font(
                    .caption
                )
                .foregroundStyle(
                    .secondary
                )
            }
        }
        .frame(
            maxWidth:
                .infinity,
            alignment:
                .leading
        )
        .padding(
            18
        )
        .background(
            MelonomeTheme.card
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }


    // =====================================
    // 初期曲
    // =====================================

    @MainActor
    private func loadInitialVideo()
        async {

        // ① 前回の曲

        if let lastVideo =
                lastPlayedManager
                    .load() {

            selectedVideo =
                lastVideo

            currentVideoID =
                lastVideo.id

            shouldAutoplay =
                false

            return
        }


        // ② お気に入りランダム

        if let randomFavorite =
                favoritesManager
                    .favorites
                    .randomElement() {

            selectedVideo =
                randomFavorite

            currentVideoID =
                randomFavorite.id

            shouldAutoplay =
                false

            return
        }


        // ③ 初回

        do {

            let video =
                try await youtubeService
                    .fetchVideo(
                        videoID:
                            currentVideoID
                    )

            selectedVideo =
                video

            shouldAutoplay =
                false

        } catch {

            print(
                "初期動画情報取得失敗:",
                error
            )
        }
    }


    // =====================================
    // シャッフル
    // =====================================

    private func startShuffle() {

        guard let video =
                shuffleManager
                    .startShuffle(
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
    }


    // =====================================
    // 再生速度
    // =====================================

    private func updatePlaybackRate(
        currentSpeed:
            Double,
        force:
            Bool = false
    ) {

        if runningMode
            == .manual {

            playbackRate =
                manualPlaybackRate

            lastAppliedRate =
                manualPlaybackRate

            return
        }


        let minimumRate =
            0.6

        let originalMinimumRate =
            0.4

        let speedRange =
            5.0

        let minimumSpeed =
            targetSpeed
            - speedRange


        let calculatedRate:
            Double


        if currentSpeed
            >= targetSpeed {

            switch runningMode {

            case .normal:

                calculatedRate =
                    1.0


            case .boost:

                let excess =
                    currentSpeed
                    - targetSpeed

                let increase =
                    (
                        1.0
                        - originalMinimumRate
                    )
                    / speedRange

                calculatedRate =
                    1.0
                    + excess
                    * increase


            case .manual:

                calculatedRate =
                    manualPlaybackRate
            }


        } else if currentSpeed
            <= minimumSpeed {

            calculatedRate =
                originalMinimumRate


        } else {

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


        let maximumRate =
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


        if runningMode
            == .normal,
           currentSpeed
            >= targetSpeed {

            if abs(
                lastAppliedRate - 1
            ) > 0.001 {

                playbackRate =
                    1

                lastAppliedRate =
                    1

                lastRateChangeTime =
                    Date()
            }

            return
        }


        if !force {

            if abs(
                limitedRate
                - lastAppliedRate
            ) < 0.05 {

                return
            }


            if Date()
                .timeIntervalSince(
                    lastRateChangeTime
                ) < 1 {

                return
            }
        }


        playbackRate =
            limitedRate

        lastAppliedRate =
            limitedRate

        lastRateChangeTime =
            Date()
    }
}
