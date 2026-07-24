import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {

    let videoID: String

    @Binding
    var playbackRate: Double

    func makeCoordinator() -> Coordinator {

        Coordinator()
    }

    func makeUIView(
        context: Context
    ) -> WKWebView {

        let configuration =
            WKWebViewConfiguration()

        configuration
            .allowsInlineMediaPlayback = true

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.scrollView
            .isScrollEnabled = false

        webView.scrollView
            .bounces = false

        loadVideo(
            webView: webView,
            videoID: videoID
        )

        return webView
    }

    func updateUIView(
        _ webView: WKWebView,
        context: Context
    ) {

        // 同じ速度なら処理しない
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

        let javascript = """
        (() => {

            const videos =
                document.getElementsByTagName(
                    'video'
                );

            if (videos.length > 0) {

                videos[0].playbackRate =
                    \(playbackRate);

                return videos[0].playbackRate;
            }

            return null;

        })();
        """

        webView.evaluateJavaScript(
            javascript
        ) { _, error in

            if let error = error {

                print(
                    "Playback rate change failed:",
                    error.localizedDescription
                )
            }
        }
    }

    private func loadVideo(
        webView: WKWebView,
        videoID: String
    ) {

        let embedURLString =
            "https://www.youtube.com/embed/\(videoID)"
            + "?playsinline=1"
            + "&controls=1"
            + "&enablejsapi=1"

        guard let url =
                URL(
                    string:
                        embedURLString
                )
        else {
            return
        }

        var request =
            URLRequest(url: url)

        // YouTube埋め込み再生に必要
        request.setValue(
            "https://localhost/",
            forHTTPHeaderField:
                "Referer"
        )

        webView.load(request)
    }

    class Coordinator {

        var lastPlaybackRate: Double?
    }
}
