//
//  MapView.swift
//  LeaveGo
//
//  Created by 이치훈 on 9/21/25.
//

import SwiftUI
import NMapsMap
import CoreLocation

// MARK: - MapView
struct MapView: View {
    @Environment(MapViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack {
            NaverMapView()
                .environment(viewModel)
            
            // Map Launch Screen
            if !viewModel.isLocationLoaded {
                loadingOverlay
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .task {
            await waitForLocationAndFetch()
        }
        .alert("위치 오류", isPresented: $viewModel.showLocationError) {
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color("lgAccentColor")
                .ignoresSafeArea()
            
            Image("img_logoWithNoBg")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: min(max(UIScreen.main.bounds.width * 0.28, 90), 140))
                .colorScheme(.light)
        }
    }
    
    private func waitForLocationAndFetch() async {
        // 위치 로드 대기
        while !viewModel.isLocationLoaded {
            try? await Task.sleep(for: .milliseconds(100))
        }
        
        // 위치 로드 성공 시에만 API 호출
        if viewModel.userLocation != nil {
            await viewModel.fetchPlaceList()
        }
    }
}

// MARK: - NaverMapView
struct NaverMapView: UIViewRepresentable {
    
    @Environment(MapViewModel.self) private var viewModel
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        
        // 기본 설정
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 15
        view.mapView.isIndoorMapEnabled = true
        view.showLocationButton = true
        view.showCompass = true
        
        // 지도 터치 델리게이트 설정
        view.mapView.touchDelegate = context.coordinator
        
        // 사용자 위치 오버레이
        let locationOverlay = view.mapView.locationOverlay
        locationOverlay.icon = NMFOverlayImage(name: "img_userLocation")
        locationOverlay.iconWidth = 25
        locationOverlay.iconHeight = 25
        locationOverlay.anchor = CGPoint(x: 0.5, y: 0.5)
        locationOverlay.circleRadius = 0
        
        // 기본 위치 (서울)
        let cameraUpdate = NMFCameraUpdate(scrollTo: viewModel.cameraPosition)
        view.mapView.moveCamera(cameraUpdate)
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        let coordinator = context.coordinator
        
        if let location = viewModel.userLocation,
           !coordinator.hasMovedToUserLocation {
            let userCoord = NMGLatLng(lat: location.latitude,
                                      lng: location.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: userCoord)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
            uiView.mapView.moveCamera(cameraUpdate)
            
            uiView.mapView.locationOverlay.location = userCoord
            uiView.mapView.locationOverlay.hidden = false
            
            coordinator.hasMovedToUserLocation = true
        }
        
        coordinator.updateMarkers(on: uiView.mapView, with: viewModel.placeList)
        
        coordinator.updateSelectedMarker(selectedId: viewModel.selectedPlaceId)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, NMFMapViewTouchDelegate {
        private var viewModel: MapViewModel
        
        // 마커 캐시
        private var currentMarkers: [String: NMFMarker] = [:]
        private var cachedPlaceIds: Set<String> = []
        
        // 상태 플래그
        var hasMovedToUserLocation = false
        
        // 공유 아이콘 (메모리 최적화)
        private let defaultIcon = NMF_MARKER_IMAGE_BLACK
        private let selectedIcon = NMF_MARKER_IMAGE_BLACK
        
        init(viewModel: MapViewModel) {
            self.viewModel = viewModel
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
            marker.iconImage = defaultIcon
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
                    self?.viewModel.selectedPlaceId = placeId
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
                viewModel.selectedPlaceId = nil
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
}
