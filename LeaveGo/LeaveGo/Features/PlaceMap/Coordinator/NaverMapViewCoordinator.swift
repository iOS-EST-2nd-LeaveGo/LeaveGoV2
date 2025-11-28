//
//  Coordinator.swift
//  LeaveGo
//
//  Created by 이치훈 on 11/28/25.
//

import NMapsMap
    
class NaverMapViewCoordinator: NSObject, NMFMapViewTouchDelegate {
    
    weak var naverMapViewDelegate: NaverMapViewDelegate?
    
    // 마커 캐시
    private var currentMarkers: [String: NMFMarker] = [:]
    private var cachedPlaceIds: Set<String> = []
    
    // 상태 플래그
    var hasMovedToUserLocation = false
    
    // 공유 아이콘 (메모리 최적화)
    private let defaultIcon = "img_logoWithNoBg"
    private let selectedIcon = "img_userAnnotationPlaceholder"
    
    init(viewModel: MapViewModel) {
        naverMapViewDelegate = viewModel
    }
    
    // MARK: - 마커 관리
    
    func updateMarkers(on mapView: NMFMapView, with placeList: [PlaceDTO]) {
        let newIds = Set(placeList.map { $0.id })
        
        // 변경 없으면 스킵
        guard cachedPlaceIds != newIds else { return }
        
        // 1. 삭제: 새 데이터에 없는 기존 마커 제거
        let toRemove = cachedPlaceIds.subtracting(newIds)
        for id in toRemove {
            removeMarker(id: id)
        }
        
        // 2. 추가: 기존에 없는 새 마커 생성
        let toAdd = newIds.subtracting(cachedPlaceIds)
        for place in placeList where toAdd.contains(place.id) {
            let marker = createMarker(from: place)
            marker.mapView = mapView
            currentMarkers[place.id] = marker
        }
        
        cachedPlaceIds = newIds
    }
    
    private func createMarker(from place: PlaceDTO) -> NMFMarker {
        let marker = NMFMarker()
        
        // 위치 설정 (mapX: 경도, mapY: 위도)
        if let latStr = place.mapY, let lngStr = place.mapX,
           let lat = Double(latStr), let lng = Double(lngStr) {
            marker.position = NMGLatLng(lat: lat, lng: lng)
        }
        
        // 스타일 설정
        marker.iconImage = NMFOverlayImage(name: defaultIcon)
        marker.iconTintColor = .systemBlue
        marker.width = 24
        marker.height = 32
        
        // 캡션 설정
        marker.captionText = place.title
        marker.captionTextSize = 12
        marker.captionColor = UIColor.black // error: Thread 1: signal SIGABRT
        marker.captionHaloColor = UIColor.white
        marker.captionMinZoom = 14
        
        // userInfo에 ID 저장
        marker.userInfo = ["placeId": place.id]
        
        // 탭 핸들러
        marker.touchHandler = { [weak self] overlay -> Bool in
            guard let placeId = overlay.userInfo["placeId"] as? String else {
                return true
            }
            
            Task { @MainActor in
                await self?.naverMapViewDelegate?.setSelectedPlaceId(id: placeId)
            }
            return true
        }
        
        return marker
    }
    
    private func removeMarker(id: String) {
        guard let marker = currentMarkers[id] else { return }
        marker.touchHandler = nil
        marker.mapView = nil
        currentMarkers.removeValue(forKey: id)
    }
    
    // MARK: - 선택 상태 업데이트
    
    func updateSelectedMarker(selectedId: String?) {
        for (id, marker) in currentMarkers {
            let isSelected = (id == selectedId)
            
            // 선택된 마커 강조
            marker.iconTintColor = isSelected ? .systemOrange : .systemBlue
            marker.width = isSelected ? 32 : 24
            marker.height = isSelected ? 42 : 32
            marker.zIndex = isSelected ? 1 : 0
        }
    }
    
    // MARK: - NMFMapViewTouchDelegate
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // 지도 빈 영역 탭 시 선택 해제
        Task { @MainActor in
            await naverMapViewDelegate?.setSelectedPlaceId(id: nil)
        }
    }
    
    // MARK: - 메모리 정리
    
    deinit {
        for marker in currentMarkers.values {
            marker.touchHandler = nil
            marker.mapView = nil
        }
        currentMarkers.removeAll()
    }
}
