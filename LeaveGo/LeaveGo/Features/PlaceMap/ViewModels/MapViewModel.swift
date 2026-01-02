//
//  MapViewModel.swift
//  LeaveGo
//
//  Created by 이치훈 on 11/21/25.
//

import SwiftUI
import CoreLocation
import NMapsMap

// MARK: NaverMapViewDelegate Protocol
protocol NaverMapViewDelegate: AnyObject {
    func setSelectedPlaceID(id: String?) async
}

@MainActor
@Observable
final class MapViewModel {
    
    // MARK: - Properties
    public var userLocation: CLLocationCoordinate2D?
    public var placeList: [PlaceDTO] = []
    public var selectedPlaceID: String?
    private var previousSelectedPlaceID: String?
    
    /// 카메라를 이동시킬 목표 좌표 (설정하면 지도가 해당 위치로 이동)
    public var targetCameraLocation: CLLocationCoordinate2D?
    
    public var selectedPlace: PlaceDTO? {
        placeList.first { $0.id == selectedPlaceID }
    }
    
    /// 여행지 API 요청을 처리하는 리포지토리
    private let placeRepository = PlaceRepository()
    
    public var errorMessage: String = ""
    private var isPlaceListFetchLoading = false
    public var isLocationLoaded = false
    public var showLocationError = false
    
    // MARK: - Init
    
    init() {
        self.requestUserLocation()
    }
    
    // MARK: Method
    
    func getPreviousSelectedPlaceID() -> String? {
        return previousSelectedPlaceID
    }
    
    /// 선택된 장소의 위치로 카메라를 이동시킵니다
    func moveCameraToSelectedPlace() {
        guard let place = selectedPlace,
              let latStr = place.mapY,
              let lngStr = place.mapX,
              let lat = Double(latStr),
              let lng = Double(lngStr) else {
            return
        }
        
        targetCameraLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    // MARK: - LocationManager
    
    @MainActor
    public func requestUserLocation() {
        LocationManager.shared.requestLocationPermission()
        
        LocationManager.shared.requestSingleLocation { result in
            switch result {
            case .success(let location):
                print("✅ 위치 획득 성공: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                Task { @MainActor in
                    self.userLocation = location.coordinate
                    self.isLocationLoaded = true
                }
                
            case .failure(let error):
                print("❌ 위치 획득 실패: \(error.localizedDescription)")
                
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                    self.showLocationError = true
                    self.isLocationLoaded = true
                }
            }
        }
    }
    
    // MARK: - Network
    
    /// 선택된 지역의 여행지 목록을 API로부터 가져오는 함수
    @MainActor
    func fetchPlaceList() async {
        defer { isPlaceListFetchLoading = false }
        guard !isPlaceListFetchLoading else { return }
        guard let location = userLocation else { return }
        
        isPlaceListFetchLoading = true
        
        do {
            guard let body = try await placeRepository.fetchPlaceList(
                endpoint: LocationBasedEndpoint(
                    page: 1,
                    numOfRows: 30,
                    mapX: location.longitude,
                    mapY: location.latitude,
                    radius: 5000,
                    contentType: .shopping,
                    arrange: "O"
                )
            ),
            body.totalCount > 0 else {
                print(#function, "⚠️ 검색 결과 없음")
                return
            }
            
            placeList = body.items.content
            
            print(#function, "✅ \(placeList.count)개 장소 로드 완료")
        } catch {
            print(#function, "🔥 에러: \(error.localizedDescription)")
        }
    }
}

// MARK: - NaverMapViewDelegate

extension MapViewModel: NaverMapViewDelegate {
    func setSelectedPlaceID(id: String?) async {
        guard selectedPlaceID != id else {
            return
        }
        
        previousSelectedPlaceID = selectedPlaceID
        
        selectedPlaceID = id
    }
}
