import Foundation
import Combine

final class LastPlayedManager: ObservableObject {

    private let storageKey =
        "Melonome_LastPlayedVideo"


    // =====================================
    // 最後に選択した曲を保存
    // =====================================

    func save(
        _ video: YouTubeVideo
    ) {

        do {

            let data =
                try JSONEncoder()
                    .encode(
                        video
                    )

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

        } catch {

            print(
                "前回の曲の保存に失敗:",
                error
            )
        }
    }


    // =====================================
    // 前回の曲を読み込み
    // =====================================

    func load()
        -> YouTubeVideo? {

        guard let data =
                UserDefaults.standard
                    .data(
                        forKey:
                            storageKey
                    )
        else {

            return nil
        }


        do {

            return try JSONDecoder()
                .decode(
                    YouTubeVideo.self,
                    from: data
                )

        } catch {

            print(
                "前回の曲の読み込みに失敗:",
                error
            )

            return nil
        }
    }
}
