import Foundation
import CoreLocation
import Combine

final class LocationManager:
    NSObject,
    ObservableObject,
    CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()

    @Published var speed: Double = 0.0

    // 最近の速度を保存
    private var speedHistory: [Double] = []

    // 直近5回で平均
    private let smoothingCount = 5

    override init() {

        super.init()

        locationManager.delegate = self

        locationManager.desiredAccuracy =
            kCLLocationAccuracyBest

        locationManager.activityType =
            .fitness

        locationManager.requestWhenInUseAuthorization()

        locationManager.startUpdatingLocation()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else {
            return
        }

        // 無効な速度は無視
        guard location.speed >= 0 else {
            return
        }

        // m/s → km/h
        let newSpeed =
            location.speed * 3.6

        speedHistory.append(newSpeed)

        // 古いデータを削除
        if speedHistory.count > smoothingCount {

            speedHistory.removeFirst(
                speedHistory.count
                - smoothingCount
            )
        }

        // 移動平均
        let averageSpeed =
            speedHistory.reduce(0, +)
            / Double(speedHistory.count)

        speed = averageSpeed
    }
}
