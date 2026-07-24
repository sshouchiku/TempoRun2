import Foundation
import Combine

final class ShuffleManager: ObservableObject {

    @Published
    private(set)
    var queue: [YouTubeVideo] = []

    @Published
    private(set)
    var currentIndex: Int = 0

    @Published
    var isShuffleEnabled: Bool = false


    // =====================================
    // シャッフル開始
    // =====================================

    func startShuffle(
        favorites: [YouTubeVideo]
    ) -> YouTubeVideo? {

        guard !favorites.isEmpty else {
            return nil
        }

        queue = favorites.shuffled()

        currentIndex = 0

        isShuffleEnabled = true

        return queue.first
    }


    // =====================================
    // 次の曲
    // =====================================

    func next(
        favorites: [YouTubeVideo]
    ) -> YouTubeVideo? {

        guard isShuffleEnabled else {
            return nil
        }

        guard !favorites.isEmpty else {
            stop()
            return nil
        }

        // お気に入り削除などで
        // queueと現状がズレた場合に備える

        let validIDs =
            Set(
                favorites.map {
                    $0.id
                }
            )

        queue =
            queue.filter {
                validIDs.contains(
                    $0.id
                )
            }

        if queue.isEmpty {

            queue =
                favorites.shuffled()

            currentIndex = 0

            return queue.first
        }


        currentIndex += 1


        // 一周したら再シャッフル
        if currentIndex
            >= queue.count {

            let previousVideo =
                queue.last

            var newQueue =
                favorites.shuffled()


            // 曲が2曲以上ある場合は
            // 前回最後の曲と
            // 次の最初の曲が同じにならないようにする

            if newQueue.count > 1,
               let previousVideo,
               newQueue.first?.id
                == previousVideo.id {

                newQueue.swapAt(
                    0,
                    1
                )
            }

            queue =
                newQueue

            currentIndex = 0
        }

        guard queue.indices.contains(
            currentIndex
        ) else {
            return nil
        }

        return queue[
            currentIndex
        ]
    }


    // =====================================
    // シャッフル停止
    // =====================================

    func stop() {

        queue = []

        currentIndex = 0

        isShuffleEnabled = false
    }
}
