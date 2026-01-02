//
//  Coordinator.swift
//  LeaveGo
//
//  Created by 이치훈 on 11/28/25.
//

import NMapsMap
    
/// Coordinator는 네이버 맵 SDK와 SwiftUI를 연결하는 중간 관리자입니다.
///
/// **역할 1: Delegate 프로토콜 구현 (Coordinator가 필수인 이유)**
/// - 네이버 맵 SDK의 Delegate 프로토콜(NMFMapViewTouchDelegate 등)은
///   Objective-C 기반으로 NSObject 상속이 필요합니다.
/// - SwiftUI View(struct)는 NSObject를 상속받을 수 없으므로
///   Coordinator(class)를 통해 Delegate를 구현합니다.
/// - 예: 지도 빈 영역 터치, 카메라 변경 등의 이벤트 수신
///
/// **역할 2: 상태 관리 및 성능 최적화 (Coordinator를 사용하는 이유)**
/// - SwiftUI View는 상태 변경 시 재생성되지만 Coordinator는 유지됩니다.
/// - 마커 캐시, 선택 상태 등 UIKit 뷰의 생명주기 동안
///   유지되어야 하는 데이터를 관리합니다.
/// - 예: 마커 재생성 방지, 상태 플래그 유지 등
///
/// - Important:
///   - 마커 터치 이벤트는 touchHandler 클로저로 처리 가능합니다.
///   - MapViewModel 이벤트 처리는 **NaverMapViewDelegate**을 통해 처리해주세요.
///   - Coordinator가 **필수**인 이유는 Delegate 프로토콜 구현 때문입니다.
class NaverMapViewCoordinator: NSObject {
    
    // MARK: - Properties
    
    weak var naverMapViewDelegate: NaverMapViewDelegate?
    
    // 마커 캐시
    private var currentMarkers: [String: NMFMarker] = [:]
    private var cachedPlaceIDs: Set<String> = []
    
    // 상태 플래그
    var hasMovedToUserLocation = false
    
    /// 마지막으로 이동한 카메라 위치 (중복 이동 방지용)
    var lastTargetCameraLocation: CLLocationCoordinate2D?
    
    // MARK: 마커 이미지 캐시
    
    /// 장소별 마커 이미지 캐시
    private var markerImageCache: [String: NMFOverlayImage] = [:]
    private var selectedMarkerImageCache: [String: NMFOverlayImage] = [:]
    
    private let imageRepository = ImageRepository.shared
    
    private let defaultMarkerSize = CGSize(width: 50, height: 100)
    private let selectedMarkerSize = CGSize(width: 60, height: 120)
    
    /// 선택되지 않은 마커의 이미지
    private lazy var defaultMarkerImage: NMFOverlayImage? = {
        let markerView = PlaceMarkerView(isSelected: false)
        guard let uiImage = markerView.asMarkerImage(size: defaultMarkerSize) else {
            return nil
        }
        return NMFOverlayImage(image: uiImage)
    }()
    
    /// 선택된 마커의 이미지
    private lazy var selectedMarkerImage: NMFOverlayImage? = {
        let markerView = PlaceMarkerView(isSelected: true)
        guard let uiImage = markerView.asMarkerImage(size: selectedMarkerSize) else {
            return nil
        }
        return NMFOverlayImage(image: uiImage)
    }()
    
    private var markerUpdateTask: Task<Void, Never>?
    
    init(viewModel: MapViewModel) {
        naverMapViewDelegate = viewModel
    }
    
    // MARK: - updateMarkers
    
    /// 장소 목록의 변경사항을 감지하여 지도의 마커를 효율적으로 업데이트합니다.
    ///
    /// 이 메서드는 **차분(Differential) 업데이트 패턴**을 사용하여
    /// 변경된 항목만 추가/제거하므로 성능이 최적화되어 있습니다.
    ///
    /// # 알고리즘 개요
    ///
    /// ```
    /// 1. 새로운 장소 ID 집합 생성
    /// 2. 기존 캐시와 비교
    ///    - 동일하면 → 즉시 종료 (최적화)
    ///    - 다르면 → 차분 계산 진행
    /// 3. 제거할 마커 계산 (기존 - 새로운)
    /// 4. 추가할 마커 계산 (새로운 - 기존)
    /// 5. 마커 제거 및 추가 수행
    /// 6. 캐시 업데이트
    /// ```
    public func updateMarkers(on mapView: NMFMapView, with placeList: [PlaceDTO]) {
        let newIDs = Set(placeList.map { $0.id })
        
        // 변경 없으면 스킵
        guard cachedPlaceIDs != newIDs else { return }
        
        // 1. 삭제: 새 데이터에 없는 기존 마커 제거
        let toRemove = cachedPlaceIDs.subtracting(newIDs)
        for id in toRemove {
            removeMarker(id: id)
        }
        
        // 2. 추가: 기존에 없는 새 마커 생성
        let toAdd = newIDs.subtracting(cachedPlaceIDs)
        for place in placeList where toAdd.contains(place.id) {
            let marker = createMarker(from: place)
            marker.mapView = mapView
            currentMarkers[place.id] = marker
        }
        
        cachedPlaceIDs = newIDs
    }
    
    // MARK: createMarker
    
    /// PlaceDTO 데이터로부터 네이버 맵 마커를 생성하고 설정합니다.
    ///
    /// 이 메서드는 장소 정보를 기반으로 완전히 설정된 마커 객체를 생성하며,
    /// 위치, 아이콘, 캡션, 터치 이벤트 핸들러까지 모든 속성을 초기화합니다.
    private func createMarker(from place: PlaceDTO) -> NMFMarker {
        let marker = NMFMarker()
        
        // 위치 설정 (mapX: 경도, mapY: 위도)
        if let latStr = place.mapY, let lngStr = place.mapX,
           let lat = Double(latStr), let lng = Double(lngStr) {
            marker.position = NMGLatLng(lat: lat, lng: lng)
        }
        
        // 스타일 설정 - 캐시된 기본 이미지 사용
        marker.iconImage = defaultMarkerImage ?? NMFOverlayImage()
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        
        // 캡션 설정
        marker.captionText = place.title
        marker.captionTextSize = 12
        marker.captionColor = UIColor.black
        marker.captionHaloColor = UIColor.white
        marker.captionMinZoom = 14
        
        // userInfo에 ID 저장
        marker.userInfo = ["placeId": place.id]
        
        // 탭 핸들러: 오버레이가 터치될 경우 호출되는 콜백 블록
        marker.touchHandler = { [weak self] overlay -> Bool in
            guard let placeID = overlay.userInfo["placeId"] as? String else {
                return true
            }
            
            Task { @MainActor in
                await self?.naverMapViewDelegate?.setSelectedPlaceID(id: placeID)
            }
            return true
        }
        
        // 장소별 썸네일 마크를 미리 생성 및 캐싱
        if let thumbnailURLString = place.thumbnailImage,
        let thumbnailURL = URL(string: thumbnailURLString) {
            loadThumbnailAndUpdateMarker(placeID: place.id,
                                         url: thumbnailURL,
                                         marker: marker)
        }
        
        return marker
    }
    
    // MARK: removeMarker
    
    /// 지도에서 특정 ID의 마커를 제거하고 관련 리소스를 정리합니다.
    /// 메모리 누수를 방지하고 지도 성능을 최적화합니다.
    private func removeMarker(id: String) {
        guard let marker = currentMarkers[id] else { return }
        marker.touchHandler = nil
        marker.mapView = nil
        currentMarkers.removeValue(forKey: id)
        
        // 마커 썸네일 이미지 캐시 정리
        markerImageCache.removeValue(forKey: id)
        selectedMarkerImageCache.removeValue(forKey: id)
    }
    
    // MARK: updateSelectedMarker
    
    /// 선택된 마커를 최적화된 방식으로 업데이트합니다.
    ///
    /// 이전 선택과 현재 선택 마커 **최대 2개만** 업데이트하여 성능을 극대화합니다.
    /// 모든 마커를 순회하는 기존 방식(O(n))과 달리, 변경된 마커만 직접 접근하여
    /// 업데이트하므로 O(1) 복잡도를 달성합니다.
    ///
    /// - Parameters:
    ///   - selectedID: 현재 선택된 마커의 ID
    ///   - previousSelectedID: 이전에 선택되었던 마커의 ID
    ///
    /// - Note: 캐시된 이미지를 재사용하므로 이미지 재생성 비용이 발생하지 않습니다.
    public func updateSelectedMarker(selectedID: String?, previousSelectedID: String?) {
        
        markerUpdateTask?.cancel()
        
        if let prevID = previousSelectedID,
           let prevMarker = currentMarkers[prevID] {
            prevMarker.hidden = true
        }
        
        if let newID = selectedID,
           let newMarker = currentMarkers[newID] {
            newMarker.hidden = true
        }
        
        markerUpdateTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(50))
            
            guard !Task.isCancelled else { return }
            
            // 1. 이전 선택 마커를 기본 스타일(deselected)로 복원
            if let prevID = previousSelectedID,
               let prevMarker = self.currentMarkers[prevID] {
                prevMarker.iconImage = self.markerImageCache[prevID] ?? self.defaultMarkerImage ?? NMFOverlayImage()
                prevMarker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                prevMarker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                prevMarker.zIndex = 0
                prevMarker.hidden = false
            }
            
            // 2. 새로 선택된 마커를 강조 스타일(selected)로 변경
            if let newID = selectedID,
               let newMarker = self.currentMarkers[newID] {
                newMarker.iconImage = selectedMarkerImageCache[newID] ?? selectedMarkerImage ?? NMFOverlayImage()
                newMarker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                newMarker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                newMarker.zIndex = 1
                newMarker.hidden = false
            }
        }
    }
    
    // MARK: loadThumbnailAndUpdateMarker
    
    /// 썸네일 이미지가 그려진 장소 marker를 생성해 캐싱합니다.
    ///
    /// - Parameters:
    ///   - placeID: 작업을 진행할 장소의 ID
    ///   - url: 장소 썸네일 이미지의 url
    ///   - marker: 다시 그릴 Marker의 class 참조
    ///
    /// - Note: 초기 시점엔 썸네일 이미지가 없는 'defaultMarkerImage' 프로퍼티를 올려놓습니다. 이후 장소 썸네일 이미지 Load가 끝나면 이 함수가 실행되어 썸네일이 포함된 마커 이미지로 다시 그립니다.
    private func loadThumbnailAndUpdateMarker(placeID: String,
                                              url: URL,
                                              marker: NMFMarker) {
        if let cachedImage = markerImageCache[placeID] {
            marker.iconImage = cachedImage
            return
        }
        
        Task { @MainActor in
            guard let thumbnailImage = await imageRepository.loadImage(from: url) else {
                return
            }
            
            // deselected 버전 marker image
            let markerView = PlaceMarkerView(isSelected: false, thumbnail: thumbnailImage)
            guard let uiImage = markerView.asMarkerImage(size: defaultMarkerSize) else {
                return
            }
            
            let overlayImage = NMFOverlayImage(image: uiImage)
            self.markerImageCache[placeID] = overlayImage
            
            // selected 버전 marker image
            let selectedMarkerView = PlaceMarkerView(isSelected: true, thumbnail: thumbnailImage)
            if let selectedUIImage = selectedMarkerView.asMarkerImage(size: selectedMarkerSize) {
                self.selectedMarkerImageCache[placeID] = NMFOverlayImage(image: selectedUIImage)
            }
            
            if marker.mapView != nil {
                marker.iconImage = overlayImage
            }
        }
    }
    
    // MARK: - DeInit
    
    deinit {
        for marker in currentMarkers.values {
            marker.touchHandler = nil
            marker.mapView = nil
        }
        currentMarkers.removeAll()
        markerImageCache.removeAll()
        selectedMarkerImageCache.removeAll()
        markerUpdateTask?.cancel()
    }
}

// MARK: - NMFMapViewTouchDelegate

extension NaverMapViewCoordinator: NMFMapViewTouchDelegate {
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // 지도 빈 영역 탭 시 선택 해제
        Task { @MainActor in
            await naverMapViewDelegate?.setSelectedPlaceID(id: nil)
        }
    }
    
}
