//
//  LocationManager.swift
//  LeaveGo
//
//  Created by 이치훈 on 9/23/25.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Location Error
/// 위치 관련 에러를 나타내는 열거형
///
/// LocationManager에서 발생할 수 있는 다양한 에러 상황을 정의합니다.
enum LocationError: Error {
    case permissionDenied /// 위치 권한이 거부
    case locationServicesDisabled /// 위치 서비스가 비활성화
    case locationServicesRestricted /// 위치 서비스가 제한된 경우
    case failedToGetLocation /// 위치를 가져올 수 없음
    case unknown /// 알 수 없는 오류
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "위치 권한이 거부되었습니다."
        case .locationServicesDisabled:
            return "위치 서비스가 비활성화되어 있습니다."
        case .locationServicesRestricted:
            return "위치 서비스가 제한되어 있습니다. 시스템 관리자에게 문의하세요."
        case .failedToGetLocation:
            return "위치를 가져올 수 없습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

// MARK: - LocationManager
/// 위치 정보와 방향(heading) 정보를 관리하는 싱글톤 매니저 클래스
///
/// CoreLocation 프레임워크를 래핑하여 앱 전체에서 일관된 위치 서비스를 제공합니다.
/// Combine과 클로저 기반의 두 가지 방식으로 위치 업데이트를 구독할 수 있습니다.
///
/// ## 주요 기능:
/// - 위치 권한 관리 및 요청
/// - 실시간 위치 추적 (지속적/일회성)
/// - 방향(Heading) 정보 추적
/// - 지오코딩 / 리버스 지오코딩
/// - 거리 계산
///
/// ## 사용 예시:
/// ```swift
/// // 싱글톤 인스턴스 접근
/// let manager = LocationManager.shared
///
/// // 권한 요청
/// manager.requestLocationPermission()
///
/// // 일회성 위치 요청
/// manager.requestSingleLocation { result in
///     switch result {
///     case .success(let location):
///         print("위치: \(location.coordinate)")
///     case .failure(let error):
///         print("에러: \(error)")
///     }
/// }
///
/// // 지속적 위치 추적
/// let id = manager.subscribeToLocationUpdates { result in
///     // 위치 업데이트마다 호출
/// }
/// ```
///
/// ## SwiftUI에서 사용:
/// ```swift
/// @StateObject private var locationManager = LocationManager.shared
///
/// var body: some View {
///     Text("위치: \(locationManager.currentLocation?.coordinate.latitude ?? 0)")
///         .onAppear {
///             locationManager.startUpdatingLocation()
///         }
/// }
/// ```
///
/// - Important: Info.plist에 위치 권한 설명을 반드시 추가해야 합니다:
///   - `NSLocationWhenInUseUsageDescription`
///   - `NSLocationAlwaysAndWhenInUseUsageDescription` (백그라운드 사용시)
final class LocationManager: NSObject {
    
    // MARK: - Singleton
    /// LocationManager의 싱글톤 인스턴스
    ///
    /// 앱 전체에서 하나의 인스턴스만 사용하여 메모리 효율성과 일관성을 보장합니다.
    static let shared = LocationManager()
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    // Combine Publishers
    /// 현재 위치 정보를 발행하는 Publisher
    /// - Note: SwiftUI에서 @Published 프로퍼티로 직접 구독 가능
    @Published private(set) var currentLocation: CLLocation?
    
    /// 현재 방향(heading) 정보를 발행하는 Publisher
    /// - Note: 나침반 기능이나 지도 회전에 사용
    @Published private(set) var currentHeading: CLHeading?
    
    /// 현재 위치 권한 상태
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    
    /// 발생한 위치 관련 에러
    @Published private(set) var locationError: LocationError?
    
    // Closure-based callbacks
    private var locationUpdateHandlers: [UUID: (Result<CLLocation, LocationError>) -> ()] = [:]
    private var oneTimeLocationHandlers: [(Result<CLLocation, LocationError>) -> ()] = []
    private var headingUpdateHandlers: [UUID: (CLHeading) -> ()] = [:]
    
    // Configuration
    /// 위치 정확도 설정
    ///
    /// 더 높은 정확도는 배터리를 더 많이 소모합니다.
    /// - `kCLLocationAccuracyBest`: 최고 정확도
    /// - `kCLLocationAccuracyNearestTenMeters`: 10미터 정확도
    /// - `kCLLocationAccuracyHundredMeters`: 100미터 정확도
    /// - `kCLLocationAccuracyKilometer`: 1km 정확도
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest {
        didSet {
            locationManager.desiredAccuracy = desiredAccuracy
        }
    }
    
    /// 위치 업데이트 최소 거리 (미터)
    ///
    /// 이 거리만큼 이동해야 새로운 위치 업데이트가 발생합니다.
    /// 작은 값일수록 더 자주 업데이트되지만 배터리 소모가 증가합니다.
    var distanceFilter: CLLocationDistance = 10 {
        didSet {
            locationManager.distanceFilter = distanceFilter
        }
    }
    
    /// Heading 업데이트 최소 각도 (도)
    ///
    /// 이 각도 이상 회전해야 새로운 heading 업데이트가 발생합니다.
    /// 기본값: 5도
    var headingFilter: CLLocationDegrees = 5 {
        didSet {
            locationManager.headingFilter = headingFilter
        }
    }
    
    /// Heading 측정 시 기기 방향
    ///
    /// 기기가 어떤 방향으로 놓여있는지에 따라 heading 계산이 달라집니다.
    /// 기본값: `.portrait`
    var headingOrientation: CLDeviceOrientation = .portrait {
        didSet {
            locationManager.headingOrientation = headingOrientation
        }
    }
    
    // MARK: - Initialization
    /// - Note: 외부에서 인스턴스를 생성할 수 없으며, `LocationManager.shared`를 통해서만 접근 가능합니다.
    private override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        setupLocationManager()
        
        Task {
            await checkInitialLocationServicesStatus()
        }
    }
    
    // MARK: - Setup
    /// LocationManager 초기 설정
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
        locationManager.headingFilter = headingFilter
        locationManager.headingOrientation = headingOrientation
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .other
    }
    
    @MainActor
    private func checkInitialLocationServicesStatus() async {
        let isEnabled = await checkLocationServicesEnabled()
        if !isEnabled {
            self.locationError = .locationServicesDisabled
            print("⚠️ 위치 서비스가 시스템 설정에서 비활성화되어 있습니다")
        }
    }
    
    func checkLocationServicesEnabled() async -> Bool {
        return await withCheckedContinuation { continuation in
            Task.detached(priority: .background) {
                let isEnabled = CLLocationManager.locationServicesEnabled()
                continuation.resume(returning: isEnabled)
            }
            
        }
    }
    
    // MARK: - Public Methods
    
    /// 위치 권한을 요청합니다.
    ///
    /// 권한 상태에 따라 적절한 동작을 수행합니다:
    /// - `.notDetermined`: 사용자에게 권한 요청 다이얼로그 표시
    /// - `.denied` / `.restricted`: `locationError`에 `.permissionDenied` 설정
    /// - `.authorized`: 이미 권한이 있으므로 별도 동작 없음
    ///
    /// ## 사용 예시:
    /// ```swift
    /// LocationManager.shared.requestLocationPermission()
    /// ```
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = .permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            locationError = .unknown
        }
    }
    
    /// 앱 사용 여부와 관계없이 사용자의 위치 서비스 사용 권한을 요청합니다.
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// 위치 업데이트를 시작합니다.
    ///
    /// 위치 서비스가 활성화되어 있고 권한이 있는 경우 지속적인 위치 업데이트를 시작합니다.
    /// `distanceFilter` 거리만큼 이동할 때마다 새로운 위치가 업데이트됩니다.
    ///
    /// ## 사용 예시:
    /// ```swift
    /// LocationManager.shared.startUpdatingLocation()
    /// ```
    ///
    /// - Note: 배터리 소모를 줄이려면 필요하지 않을 때 `stopUpdatingLocation()`을 호출하세요.
    func startUpdateingLocation() {
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            requestLocationPermission()
        case .denied:
            locationError = .permissionDenied
        case .restricted:
            locationError = .locationServicesRestricted
        @unknown default:
            locationError = .unknown
        }
    }
    
    /// 위치 업데이트를 중지합니다.
    ///
    /// 배터리 절약을 위해 위치 추적이 필요하지 않을 때 호출하세요.
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationUpdateHandlers.removeAll()
    }
    
    /// 디바이스 방향(Heading) 업데이트를 시작합니다.
    ///
    /// 나침반 기능이나 지도 회전에 필요한 방향 정보를 추적합니다.
    /// `headingFilter` 각도 이상 변화할 때마다 업데이트됩니다.
    ///
    /// ## 사용 예시:
    /// ```swift
    /// LocationManager.shared.startUpdatingHeading()
    ///
    /// // Heading 정보 사용
    /// if let heading = LocationManager.shared.currentHeading {
    ///     let degrees = heading.trueHeading  // 진북 기준 0-360도
    /// }
    /// ```
    ///
    /// - Note: 모든 디바이스가 heading을 지원하지는 않습니다.
    func startUpdatingHeading() {
        guard CLLocationManager.headingAvailable() else {
            print("Heading is not available on this device")
            return
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingHeading()
        case .notDetermined:
            requestLocationPermission()
        case .denied:
            locationError = .permissionDenied
        case .restricted:
            locationError = .locationServicesRestricted
        @unknown default:
            locationError = .unknown
        }
    }
    
    /// 디바이스 방향(Heading) 업데이트를 중지합니다.
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
        headingUpdateHandlers.removeAll()
    }
    
    /// Heading 업데이트를 구독합니다.
    ///
    /// - Parameter handler: 방향이 변경될 때마다 호출되는 콜백
    /// - Returns: 구독 해제에 사용할 고유 ID
    ///
    /// ## 사용 예시:
    /// ```swift
    /// let id = LocationManager.shared.subscribeToHeadingUpdates { heading in
    ///     print("진북 방향: \(heading.trueHeading)도")
    ///     print("자북 방향: \(heading.magneticHeading)도")
    /// }
    ///
    /// // 나중에 구독 해제
    /// LocationManager.shared.unsubscribeFromHeadingUpdates(id: id)
    /// ```
    @discardableResult
    func subscribeHeadingUpdates(handler: @escaping (CLHeading) -> ()) -> UUID {
        let id = UUID()
        headingUpdateHandlers[id] = handler
        
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways {
            startUpdatingHeading()
        }
        
        return id
    }
    
    /// Heading 업데이트 구독 해제
    func unsubscribeFromHeadingUpdate(id: UUID) {
        headingUpdateHandlers.removeValue(forKey: id)
        
        if headingUpdateHandlers.isEmpty {
            stopUpdatingHeading()
        }
    }
    
    /// 나침반 보정이 필요한지 확인
    func shouldDisplayHeadingCalibration() -> Bool {
        return locationManager.heading?.headingAccuracy ?? -1 < 0
    }
    
    /// 한 번만 위치를 가져옵니다.
    ///
    /// 지속적인 추적이 필요없고 현재 위치만 필요한 경우 사용합니다.
    /// 위치를 가져오면 자동으로 업데이트가 중지됩니다.
    ///
    /// - Parameter completion: 위치 결과를 받을 콜백 (성공 또는 실패)
    ///
    /// ## 사용 예시:
    /// ```swift
    /// LocationManager.shared.requestSingleLocation { result in
    ///     switch result {
    ///     case .success(let location):
    ///         print("현재 위치: \(location.coordinate)")
    ///     case .failure(let error):
    ///         print("에러: \(error.localizedDescription)")
    ///     }
    /// }
    /// ```
    func requestSingleLocation(completion: @escaping (Result<CLLocation, LocationError>) -> ()) {
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            oneTimeLocationHandlers.append(completion)
            locationManager.requestLocation()
        case .notDetermined:
            oneTimeLocationHandlers.append(completion)
            requestLocationPermission()
        case .denied:
            completion(.failure(.permissionDenied))
        case .restricted:
            completion(.failure(.locationServicesRestricted))
        @unknown default:
            completion(.failure(.unknown))
        }
    }
    
    /// 지속적인 위치 업데이트를 구독합니다.
    ///
    /// - Parameter handler: 위치가 업데이트될 때마다 호출되는 콜백
    /// - Returns: 구독 해제에 사용할 고유 ID
    ///
    /// ## 사용 예시:
    /// ```swift
    /// class ViewController: UIViewController {
    ///     private var subscriptionID: UUID?
    ///
    ///     override func viewDidLoad() {
    ///         subscriptionID = LocationManager.shared.subscribeToLocationUpdates { result in
    ///             switch result {
    ///             case .success(let location):
    ///                 // 새 위치로 UI 업데이트
    ///             case .failure(let error):
    ///                 // 에러 처리
    ///             }
    ///         }
    ///     }
    ///
    ///     override func viewWillDisappear(_ animated: Bool) {
    ///         if let id = subscriptionID {
    ///             LocationManager.shared.unsubscribeFromLocationUpdates(id: id)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Important: 메모리 누수 방지를 위해 뷰가 사라질 때 반드시 구독을 해제하세요.
    @discardableResult
    func subscribeToLocationUpdates(handler: @escaping (Result<CLLocation, LocationError>) -> ()) -> UUID {
        let id = UUID()
        locationUpdateHandlers[id] = handler
        
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways {
            startUpdateingLocation()
        }
        
        return id
    }
    
    /// 위치 업데이트 구독을 해제합니다.
    ///
    /// - Parameter id: `subscribeToLocationUpdates`에서 반환된 구독 ID
    
    func unsubscribeFromLocationUpdates(id: UUID) {
        locationUpdateHandlers.removeValue(forKey: id)
        
        if locationUpdateHandlers.isEmpty {
            stopUpdatingLocation()
        }
    }
    
    /// 특정 위치까지의 거리 계산
    func distance(from location: CLLocation) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }
        return currentLocation.distance(from: location)
    }
    
    /// 좌표를 주소로 변환합니다 (리버스 지오코딩).
    ///
    /// - Parameters:
    ///   - location: 변환할 위치 객체
    ///   - completion: 변환 결과를 받을 콜백
    ///
    /// ## 사용 예시:
    /// ```swift
    /// if let location = LocationManager.shared.currentLocation {
    ///     LocationManager.shared.reverseGeocode(location: location) { result in
    ///         switch result {
    ///         case .success(let placemark):
    ///             print("주소: \(placemark.name ?? "알 수 없음")")
    ///             print("도시: \(placemark.locality ?? "")")
    ///         case .failure(let error):
    ///             print("변환 실패: \(error)")
    ///         }
    ///     }
    /// }
    /// ```
    func reverseGeocode(location: CLLocation, completion: @escaping (Result<CLPlacemark, Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(.failure(LocationError.failedToGetLocation))
                return
            }
            
            completion(.success(placemark))
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    /// 위치가 업데이트되었을 때 호출됩니다.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        locationError = nil
        
        // 지속적인 업데이트 핸들러들에게 알림
        locationUpdateHandlers.values.forEach { handler in
            handler(.success(location))
        }
        
        // 일회성 핸들러들 처리
        if !oneTimeLocationHandlers.isEmpty {
            oneTimeLocationHandlers.forEach { handler in
                handler(.success(location))
            }
            oneTimeLocationHandlers.removeAll()
        }
    }
    
    /// 위치 업데이트 실패 시 호출됩니다.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        let locationError: LocationError
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .permissionDenied
            case .locationUnknown:
                locationError = .failedToGetLocation
            default:
                locationError = .unknown
            }
        } else {
            locationError = .unknown
        }
        
        self.locationError = locationError
        
        // 에러를 핸들러들에게 전달
        locationUpdateHandlers.values.forEach { handler in
            handler(.failure(locationError))
        }
        
        oneTimeLocationHandlers.forEach { handler in
            handler(.failure(locationError))
        }
        
        oneTimeLocationHandlers.removeAll()
    }
    
    /// 위치 권한이 변경되었을 때 호출됩니다 (iOS 14+).
    ///
    /// - Note: iOS 14부터는 이 메서드를 사용하며, `locationManager(_:didChangeAuthorization:)`는 deprecated되었습니다.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            
            if manager.accuracyAuthorization == .reducedAccuracy {
                print("사용자가 대략적인 위치만 허용했습니다")
            }
            if !locationUpdateHandlers.isEmpty || !oneTimeLocationHandlers.isEmpty {
                startUpdateingLocation()
            }
            
            if !headingUpdateHandlers.isEmpty {
                startUpdatingHeading()
            }
        case .denied:
            locationError = .permissionDenied
        case .restricted:
            locationError = .locationServicesRestricted
        case .notDetermined:
            break
        @unknown default:
            locationError = .unknown
        }
    }
    
    // MARK: - Heading Delegate Methods
    
    /// Heading(방향)이 업데이트되었을 때 호출됩니다.
    ///
    /// - Parameters:
    ///   - manager: 위치 관리자
    ///   - newHeading: 새로운 heading 정보
    ///     - `trueHeading`: 진북 기준 방향 (0-360도)
    ///     - `magneticHeading`: 자북 기준 방향 (0-360도)
    ///     - `headingAccuracy`: 정확도 (음수면 보정 필요)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading
        
        headingUpdateHandlers.values.forEach { handler in
            handler(newHeading)
        }
    }
    
    /// 나침반 보정 UI를 표시할지 결정합니다.
    ///
    /// - Returns: `true`를 반환하면 iOS가 자동으로 나침반 보정 UI를 표시합니다.
    ///           `false`를 반환하면 보정 UI를 표시하지 않습니다.
    ///
    /// - Note: 사용자가 디바이스를 8자 모양으로 움직여 나침반을 보정할 수 있습니다.
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}

// MARK: - Combine extension
extension LocationManager {
    
    /// Combine을 사용한 위치 업데이트 스트림
    ///
    /// SwiftUI나 리액티브 프로그래밍에서 사용할 수 있는 Publisher입니다.
    ///
    /// ## 사용 예시:
    /// ```swift
    /// LocationManager.shared.locationPublisher
    ///     .sink(
    ///         receiveCompletion: { completion in
    ///             if case .failure(let error) = completion {
    ///                 print("에러: \(error)")
    ///             }
    ///         },
    ///         receiveValue: { location in
    ///             print("새 위치: \(location.coordinate)")
    ///         }
    ///     )
    ///     .store(in: &cancellables)
    /// ```
    var locationPublisher: AnyPublisher<CLLocation, LocationError> {
        $currentLocation
            .compactMap { $0 }
            .setFailureType(to: LocationError.self)
            .merge(with: $locationError
                .compactMap { $0 }
                .tryMap { error in throw error }
                .mapError { $0 as? LocationError ?? .unknown }
                .map { _ in CLLocation() }
                .filter { _ in false }
            )
            .eraseToAnyPublisher()
    }
    
    /// Combine을 사용한 Heading(방향) 업데이트 스트림
    ///
    /// 나침반 UI나 지도 회전에 사용할 수 있는 Publisher입니다.
    ///
    /// ## 사용 예시:
    /// ```swift
    /// LocationManager.shared.headingPublisher
    ///     .sink { heading in
    ///         // 진북 기준 방향 (0-360도)
    ///         let trueHeading = heading.trueHeading
    ///
    ///         // UI 업데이트 (나침반 회전 등)
    ///         compassImageView.transform = CGAffineTransform(rotationAngle: -trueHeading * .pi / 180)
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    var headingPublisher: AnyPublisher<CLHeading, Never> {
        $currentHeading
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
