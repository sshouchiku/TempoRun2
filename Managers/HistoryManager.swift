import Foundation
import Combine

final class HistoryManager: ObservableObject {

    @Published
    private(set)
    var recentVideos: [YouTubeVideo] = []

    private let storageKey =
        "Melonome_RecentVideos"

    private let maximumHistoryCount =
        30


    init() {

        load()
    }


    // =====================================
    // 履歴に追加
    // =====================================

    func add(
        _ video: YouTubeVideo
    ) {

        // 同じ曲があれば一度削除
        recentVideos.removeAll {
            $0.id == video.id
        }

        // 一番上へ追加
        recentVideos.insert(
            video,
            at: 0
        )


        // 最大30曲
        if recentVideos.count
            > maximumHistoryCount {

            recentVideos =
                Array(
                    recentVideos.prefix(
                        maximumHistoryCount
                    )
                )
        }

        save()
    }


    // =====================================
    // 履歴削除
    // =====================================

    func clear() {

        recentVideos = []

        UserDefaults.standard.removeObject(
            forKey: storageKey
        )
    }


    // =====================================
    // 保存
    // =====================================

    private func save() {

        do {

            let data =
                try JSONEncoder()
                    .encode(
                        recentVideos
                    )

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

        } catch {

            print(
                "再生履歴保存失敗:",
                error
            )
        }
    }


    // =====================================
    // 読み込み
    // =====================================

    private func load() {

        guard let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {
            return
        }

        do {

            recentVideos =
                try JSONDecoder()
                    .decode(
                        [YouTubeVideo].self,
                        from: data
                    )

        } catch {

            print(
                "再生履歴読み込み失敗:",
                error
            )
        }
    }
}
