import SwiftUI

struct ContentView: View {

    @StateObject
    private var locationManager = LocationManager()

    // 目標速度
    @State
    private var targetSpeed: Double = 10.0

    // YouTube再生速度
    @State
    private var playbackRate: Double = 0.6

    // YouTube URL
    @State
    private var youtubeURL: String = ""

    // 最初に表示する動画
    @State
    private var videoID: String = "2I25AFSBm2g"

    // URLエラー
    @State
    private var urlError: String?

    // 手動テストモード
    @State
    private var manualTestMode: Bool = false

    // 最後にYouTubeへ設定した速度
    @State
    private var lastAppliedRate: Double = 0.6

    // 最後に速度変更した時刻
    @State
    private var lastRateChangeTime: Date = .distantPast


    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                Text("TempoRun 2")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // -------------------------
                // YouTube URL入力
                // -------------------------

                VStack(spacing: 10) {

                    TextField(
                        "YouTube URLを貼り付け",
                        text: $youtubeURL
                    )
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    Button("動画を読み込む") {

                        loadYouTubeVideo()
                    }
                    .buttonStyle(.borderedProminent)

                    if let urlError {

                        Text(urlError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                // -------------------------
                // YouTube
                // -------------------------

                YouTubePlayerView(
                    videoID: videoID,
                    playbackRate: $playbackRate
                )
                .id(videoID)
                .aspectRatio(
                    16 / 9,
                    contentMode: .fit
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                )

                // -------------------------
                // 現在速度
                // -------------------------

                VStack(spacing: 5) {

                    Text("Current Speed")
                        .font(.headline)

                    Text(
                        String(
                            format: "%.1f km/h",
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

                // -------------------------
                // 目標速度
                // -------------------------

                VStack(spacing: 10) {

                    Text("Target Speed")
                        .font(.headline)

                    Text(
                        String(
                            format: "%.1f km/h",
                            targetSpeed
                        )
                    )
                    .font(.title2)

                    Slider(
                        value: $targetSpeed,
                        in: 5...20,
                        step: 0.5
                    )
                }

                Divider()

                // -------------------------
                // 再生速度
                // -------------------------

                VStack(spacing: 5) {

                    Text("Playback Speed")
                        .font(.headline)

                    Text(
                        String(
                            format: "%.2fx",
                            playbackRate
                        )
                    )
                    .font(.title)
                    .fontWeight(.bold)
                }

                // -------------------------
                // 手動テスト
                // -------------------------

                VStack(spacing: 12) {

                    Toggle(
                        "Manual Test Mode",
                        isOn: $manualTestMode
                    )

                    if manualTestMode {

                        Text("音切れ確認用")
                            .font(.headline)

                        HStack {

                            Button("0.60x") {

                                applyManualRate(0.60)
                            }

                            Button("0.70x") {

                                applyManualRate(0.70)
                            }

                            Button("0.80x") {

                                applyManualRate(0.80)
                            }

                            Button("1.00x") {

                                applyManualRate(1.00)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Text(
                    manualTestMode
                    ? "Manual Test Mode中はGPS連動を停止しています"
                    : "速度変更の頻度を抑えて再生しています"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
        }

        // -------------------------
        // GPS速度変更
        // -------------------------

        .onChange(
            of: locationManager.speed
        ) { _, newSpeed in

            if !manualTestMode {

                updatePlaybackRate(
                    currentSpeed: newSpeed
                )
            }
        }

        // -------------------------
        // 目標速度変更
        // -------------------------

        .onChange(
            of: targetSpeed
        ) { _, _ in

            if !manualTestMode {

                updatePlaybackRate(
                    currentSpeed:
                        locationManager.speed
                )
            }
        }

        // -------------------------
        // Manual Mode解除時
        // GPS連動に戻す
        // -------------------------

        .onChange(
            of: manualTestMode
        ) { _, isManual in

            if !isManual {

                updatePlaybackRate(
                    currentSpeed:
                        locationManager.speed,
                    force: true
                )
            }
        }

        .onAppear {

            updatePlaybackRate(
                currentSpeed:
                    locationManager.speed,
                force: true
            )
        }
    }


    // =====================================
    // 手動速度変更
    // =====================================

    private func applyManualRate(
        _ rate: Double
    ) {

        playbackRate = rate

        lastAppliedRate = rate

        lastRateChangeTime = Date()
    }


    // =====================================
    // YouTube URL → Video ID
    // =====================================

    private func loadYouTubeVideo() {

        guard let newVideoID =
                extractYouTubeVideoID(
                    from: youtubeURL
                )
        else {

            urlError =
                "有効なYouTube URLを入力してください"

            return
        }

        urlError = nil

        videoID = newVideoID
    }


    private func extractYouTubeVideoID(
        from urlString: String
    ) -> String? {

        let trimmed =
            urlString.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard let url =
                URL(string: trimmed),
              let host =
                url.host?.lowercased()
        else {

            return nil
        }

        // ---------------------------------
        // youtu.be/VIDEO_ID
        // ---------------------------------

        if host == "youtu.be"
            || host == "www.youtu.be" {

            return url.pathComponents
                .filter {
                    $0 != "/"
                }
                .first
        }

        // ---------------------------------
        // youtube.com系
        // ---------------------------------

        if host == "youtube.com"
            || host == "www.youtube.com"
            || host == "m.youtube.com"
            || host == "music.youtube.com" {

            // watch?v=VIDEO_ID

            if url.path == "/watch" {

                let components =
                    URLComponents(
                        url: url,
                        resolvingAgainstBaseURL: false
                    )

                return components?
                    .queryItems?
                    .first(
                        where: {
                            $0.name == "v"
                        }
                    )?
                    .value
            }

            // shorts/VIDEO_ID

            if url.path
                .hasPrefix("/shorts/") {

                let parts =
                    url.pathComponents

                if let index =
                    parts.firstIndex(
                        of: "shorts"
                    ),
                   parts.indices.contains(
                    index + 1
                   ) {

                    return parts[index + 1]
                }
            }

            // embed/VIDEO_ID

            if url.path
                .hasPrefix("/embed/") {

                let parts =
                    url.pathComponents

                if let index =
                    parts.firstIndex(
                        of: "embed"
                    ),
                   parts.indices.contains(
                    index + 1
                   ) {

                    return parts[index + 1]
                }
            }
        }

        return nil
    }


    // =====================================
    // GPS速度 → YouTube再生速度
    // =====================================

    private func updatePlaybackRate(
        currentSpeed: Double,
        force: Bool = false
    ) {

        // 実際に使う最低再生速度
        let minimumRate = 0.6

        // 元の変化の仕方は維持したいので、
        // 計算上は0.4〜1.0のままにする
        let originalMinimumRate = 0.4

        // 目標速度の5km/h手前を
        // 元々の0.4x地点とする
        let speedRange = 5.0

        let minimumSpeed =
            targetSpeed - speedRange

        let calculatedRate: Double


        // -------------------------
        // 目標速度以上
        // 必ず1.0x
        // -------------------------

        if currentSpeed >= targetSpeed {

            calculatedRate = 1.0
        }

        // -------------------------
        // 目標速度 - 5km/h以下
        // -------------------------

        else if currentSpeed <= minimumSpeed {

            calculatedRate =
                originalMinimumRate
        }

        // -------------------------
        // その間
        // 元の0.4〜1.0の勾配を維持
        // -------------------------

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


        // -------------------------
        // 最低0.6xに制限
        // -------------------------

        let limitedRate =
            min(
                max(
                    calculatedRate,
                    minimumRate
                ),
                1.0
            )


        // -------------------------
        // 目標速度以上なら
        // 必ず1.0xへ戻す
        //
        // 0.96 → 1.00 の差が
        // 0.05未満でも無視しない
        // -------------------------

        if currentSpeed >= targetSpeed {

            if abs(
                lastAppliedRate - 1.0
            ) > 0.001 {

                playbackRate = 1.0

                lastAppliedRate = 1.0

                lastRateChangeTime = Date()
            }

            return
        }


        // -------------------------
        // 通常時の変更頻度制限
        // -------------------------

        if !force {

            // 前回との差が0.05未満なら
            // YouTube側の速度を変更しない

            let minimumRateDifference =
                0.05

            if abs(
                limitedRate
                - lastAppliedRate
            ) < minimumRateDifference {

                return
            }


            // 前回変更から1秒未満なら
            // 変更しない

            let minimumInterval =
                1.0

            let elapsedTime =
                Date().timeIntervalSince(
                    lastRateChangeTime
                )

            if elapsedTime
                < minimumInterval {

                return
            }
        }


        // -------------------------
        // YouTubeへ反映
        // -------------------------

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
