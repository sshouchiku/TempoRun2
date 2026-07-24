import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {

    let videoID: String

    @Binding
    var playbackRate: Double

    let autoplay: Bool

    var onVideoEnded: (() -> Void)? = nil


    // =====================================
    // Coordinator
    // =====================================

    func makeCoordinator() -> Coordinator {

        Coordinator(
            onVideoEnded: onVideoEnded
        )
    }


    // =====================================
    // WKWebView作成
    //
    // ここは最初の1回だけ
    // =====================================

    func makeUIView(
        context: Context
    ) -> WKWebView {

        let userContentController =
            WKUserContentController()


        userContentController.add(
            context.coordinator,
            name: "videoEnded"
        )


        let configuration =
            WKWebViewConfiguration()


        configuration
            .allowsInlineMediaPlayback =
                true


        configuration
            .mediaTypesRequiringUserActionForPlayback =
                []


        configuration
            .userContentController =
                userContentController


        let webView =
            WKWebView(
                frame: .zero,
                configuration: configuration
            )


        webView.scrollView
            .isScrollEnabled =
                false


        webView.scrollView
            .bounces =
                false


        webView.navigationDelegate =
            context.coordinator


        // 最初の動画IDを記録
        context.coordinator
            .currentVideoID =
                videoID


        context.coordinator
            .autoplay =
                autoplay


        context.coordinator
            .lastPlaybackRate =
                playbackRate


        // 最初の動画をロード
        loadVideo(
            webView: webView,
            videoID: videoID,
            autoplay: autoplay
        )


        return webView
    }


    // =====================================
    // SwiftUI側の状態更新
    //
    // WebViewは作り直さず
    // 同じものを使い続ける
    // =====================================

    func updateUIView(
        _ webView: WKWebView,
        context: Context
    ) {

        context.coordinator
            .onVideoEnded =
                onVideoEnded


        context.coordinator
            .autoplay =
                autoplay


        // =====================================
        // 動画IDが変わった
        //
        // 同じWKWebViewに
        // 新しい動画を読み込む
        // =====================================

        if context.coordinator
            .currentVideoID
            != videoID {

            context.coordinator
                .currentVideoID =
                    videoID


            context.coordinator
                .lastPlaybackRate =
                    playbackRate


            loadVideo(
                webView: webView,
                videoID: videoID,
                autoplay: autoplay
            )


            return
        }


        // =====================================
        // 再生速度だけ変わった
        // =====================================

        if let lastRate =
            context.coordinator
                .lastPlaybackRate,
           abs(
                lastRate
                - playbackRate
           ) < 0.001 {

            return
        }


        context.coordinator
            .lastPlaybackRate =
                playbackRate


        applyPlaybackRate(
            webView: webView,
            rate: playbackRate
        )
    }


    // =====================================
    // YouTube動画読み込み
    // =====================================

    private func loadVideo(
        webView: WKWebView,
        videoID: String,
        autoplay: Bool
    ) {

        let autoplayValue =
            autoplay
            ? "1"
            : "0"


        let embedURLString =
            "https://www.youtube.com/embed/\(videoID)"
            + "?playsinline=1"
            + "&controls=1"
            + "&enablejsapi=1"
            + "&autoplay=\(autoplayValue)"


        guard let url =
                URL(
                    string: embedURLString
                )
        else {

            return
        }


        var request =
            URLRequest(
                url: url
            )


        request.setValue(
            "https://localhost/",
            forHTTPHeaderField: "Referer"
        )


        webView.load(
            request
        )
    }


    // =====================================
    // 再生速度変更
    // =====================================

    private func applyPlaybackRate(
        webView: WKWebView,
        rate: Double
    ) {

        let javascript =
        """
        (() => {

            const videos =
                document.getElementsByTagName(
                    'video'
                );

            if (videos.length === 0) {

                return false;
            }

            videos[0].playbackRate =
                \(rate);

            return true;

        })();
        """


        webView.evaluateJavaScript(
            javascript
        ) { _, error in

            if let error {

                print(
                    "再生速度変更JSエラー:",
                    error
                )
            }
        }
    }


    // =====================================
    // Coordinator
    // =====================================

    final class Coordinator:
        NSObject,
        WKScriptMessageHandler,
        WKNavigationDelegate {

        // 現在WebViewに読み込んでいる動画
        var currentVideoID:
            String?


        // 最後に適用した速度
        var lastPlaybackRate:
            Double?


        // 自動再生するか
        var autoplay:
            Bool = false


        // 曲終了コールバック
        var onVideoEnded:
            (() -> Void)?


        init(
            onVideoEnded:
                (() -> Void)?
        ) {

            self.onVideoEnded =
                onVideoEnded
        }


        // =====================================
        // JavaScript → Swift
        //
        // 動画終了通知
        // =====================================

        func userContentController(
            _ userContentController:
                WKUserContentController,
            didReceive message:
                WKScriptMessage
        ) {

            guard message.name
                == "videoEnded"
            else {

                return
            }


            DispatchQueue
                .main
                .async {

                    self
                        .onVideoEnded?()
                }
        }


        // =====================================
        // YouTubeページ読み込み完了
        // =====================================

        func webView(
            _ webView:
                WKWebView,
            didFinish navigation:
                WKNavigation!
        ) {

            installVideoController(
                webView: webView
            )
        }


        // =====================================
        // videoタグを探して
        //
        // ・再生速度設定
        // ・終了監視
        // ・必要なら自動再生
        //
        // =====================================

        private func installVideoController(
            webView: WKWebView
        ) {

            let rate =
                lastPlaybackRate
                ?? 1.0


            let shouldAutoplay =
                autoplay


            let autoplayScript =
                shouldAutoplay
                ? """
                    const playPromise =
                        video.play();

                    if (
                        playPromise !== undefined
                    ) {

                        playPromise
                            .then(() => {

                                console.log(
                                    'Melonome autoplay success'
                                );

                            })
                            .catch(error => {

                                console.log(
                                    'Melonome autoplay failed',
                                    error
                                );
                            });
                    }
                """
                : ""


            let javascript =
            """
            (() => {

                let attempts = 0;


                function setupVideo() {

                    attempts++;


                    const videos =
                        document.getElementsByTagName(
                            'video'
                        );


                    // videoタグがまだ無い場合
                    // 少し待って再試行

                    if (
                        videos.length === 0
                    ) {

                        if (
                            attempts < 40
                        ) {

                            setTimeout(
                                setupVideo,
                                250
                            );
                        }

                        return;
                    }


                    const video =
                        videos[0];


                    // =================================
                    // 再生速度
                    // =================================

                    video.playbackRate =
                        \(rate);


                    // =================================
                    // 終了監視
                    // =================================

                    if (
                        video.dataset
                            .melonomeEndedListener
                        !== 'true'
                    ) {

                        video.dataset
                            .melonomeEndedListener =
                                'true';


                        video.addEventListener(
                            'ended',
                            function() {

                                window.webkit
                                    .messageHandlers
                                    .videoEnded
                                    .postMessage(
                                        'ended'
                                    );
                            }
                        );
                    }


                    // =================================
                    // 必要なときだけ自動再生
                    // =================================

                    \(autoplayScript)
                }


                setupVideo();

            })();
            """


            webView.evaluateJavaScript(
                javascript
            ) { _, error in

                if let error {

                    print(
                        "プレイヤー設定JSエラー:",
                        error
                    )
                }
            }
        }
    }
}
