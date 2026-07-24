import Foundation
import Combine

final class FavoritesManager:
    ObservableObject {

    @Published
    private(set)
    var favorites: [YouTubeVideo] = []

    private let storageKey =
        "TempoRun2_FavoriteVideos"

    init() {

        loadFavorites()
    }


    // =====================================
    // お気に入りか判定
    // =====================================

    func isFavorite(
        _ video: YouTubeVideo
    ) -> Bool {

        favorites.contains {
            $0.id == video.id
        }
    }


    // =====================================
    // お気に入り追加・削除
    // =====================================

    func toggleFavorite(
        _ video: YouTubeVideo
    ) {

        if let index =
            favorites.firstIndex(
                where: {
                    $0.id == video.id
                }
            ) {

            favorites.remove(
                at: index
            )

        } else {

            favorites.append(
                video
            )
        }

        saveFavorites()
    }


    // =====================================
    // 保存
    // =====================================

    private func saveFavorites() {

        do {

            let data =
                try JSONEncoder()
                    .encode(
                        favorites
                    )

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

        } catch {

            print(
                "お気に入り保存失敗:",
                error
            )
        }
    }


    // =====================================
    // 読み込み
    // =====================================

    private func loadFavorites() {

        guard let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {
            return
        }

        do {

            favorites =
                try JSONDecoder()
                    .decode(
                        [YouTubeVideo].self,
                        from: data
                    )

        } catch {

            print(
                "お気に入り読み込み失敗:",
                error
            )
        }
    }
}
