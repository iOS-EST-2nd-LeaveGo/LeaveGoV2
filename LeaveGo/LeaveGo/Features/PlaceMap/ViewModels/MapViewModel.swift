//
//  MapViewModel.swift
//  LeaveGo
//
//  Created by 이치훈 on 11/21/25.
//

import SwiftUI
import CoreLocation

@MainActor
@Observable
final class MapViewModel: ObservableObject {
    
    public var userLocation: CLLocationCoordinate2D?
    
    /// 여행지 API 요청을 처리하는 리포지토리
    private let placeRepository = PlaceRepository()
    
    private var placeList: [PlaceDTO] = []
    
    public var errorMessage: String = ""
    private var isLoading = false
    public var isLocationLoaded = false
    public var showLocationError = false
    
    // MARK: Init
    
    init() {
        self.requestUserLocation()
    }
    
    // MARK: LocationManager
    
    @MainActor
    public func requestUserLocation() {
        LocationManager.shared.requestLocationPermission()
        
        LocationManager.shared.requestSingleLocation { result in
            switch result {
            case .success(let location):
                print("✅ 위치 획득 성공: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                Task {
                    self.userLocation = location.coordinate
                    self.isLocationLoaded = true
                }
            case .failure(let error):
                print("❌ 위치 획득 실패: \(error.localizedDescription)")
                
                Task {
                    self.errorMessage = error.localizedDescription
                    self.showLocationError = true
                    self.isLocationLoaded = true
                }
            }
        }
    }
    
    // MARK: Network
    
    // , let location = userLocation
    /// 선택된 지역의 여행지 목록을 API로부터 가져오는 함수
    @MainActor
    func fetchPlaceList() async {
        defer { isLoading = false }
        guard !isLoading else { return }
        guard let location = userLocation else { return }
        
        isLoading = true
        
        do {
            guard let body = try await placeRepository.fetchPlaceList(endpoint: LocationBasedEndpoint(page: 1, numOfRows: 30, mapX: location.longitude, mapY: location.latitude, radius: 5000, contentType: .shopping, arrange: "O")),
                  body.totalCount > 0 else { return }
            
            placeList = body.items.content
            
            print(#function, "✅ successfully \(placeList) in \(location)")
        } catch {
            print(#function, "🔥 \(location) 지역에 장소가 없음")
        }
    }
}
