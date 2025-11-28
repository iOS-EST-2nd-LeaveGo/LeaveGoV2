//
//  NaverMapView.swift
//  LeaveGo
//
//  Created by 이치훈 on 11/27/25.
//

import NMapsMap
import SwiftUI

struct NaverMapView: UIViewRepresentable {
    
    @Environment(MapViewModel.self) private var viewModel
    
    /// Naver 지도의 UIKit 뷰를 생성하고 초기 설정을 수행합니다.
    ///
    /// 이 메서드는 UIViewRepresentable 프로토콜의 필수 구현으로,
    /// SwiftUI 환경에서 UIKit 기반의 NMFNaverMapView를 사용할 수 있도록 합니다.
    /// 메서드는 뷰의 생명주기 동안 단 한 번만 호출됩니다. (초기화용)
    ///
    /// - Parameter context: SwiftUI에서 제공하는 컨텍스트 객체
    ///   - coordinator: 델리게이트 패턴 처리를 위한 Coordinator 인스턴스
    ///   - environment: SwiftUI 환경 값들
    ///   - transaction: 애니메이션 정보
    ///
    /// - Returns: 설정이 완료된 NMFNaverMapView 인스턴스
    ///
    /// - Note: 반환된 뷰는 이후 `updateUIView(_:context:)`에서 업데이트됩니다
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
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.5666, lng: 126.9784))
        view.mapView.moveCamera(cameraUpdate)
        
        return view
    }
    
    /// 이 메서드는 UIViewRepresentable 프로토콜의 필수 구현으로,
    /// SwiftUI의 상태(@State, @Binding, @Environment 등)가 변경될 때마다 자동으로 호출됩니다.
    /// ViewModel의 변경사항을 UIKit 기반 지도 뷰에 반영하는 역할을 합니다.
    ///
    /// **호출 시점:**
    /// - viewModel.userLocation 변경 시
    /// - viewModel.placeList 변경 시
    /// - viewModel.selectedPlaceId 변경 시
    /// - **부모 뷰의 다른 상태 변경으로 인한 재렌더링 시**
    ///
    /// - Parameters:
    ///   - uiView: 업데이트할 네이버 지도 뷰 인스턴스
    ///   - context: SwiftUI에서 제공하는 컨텍스트 (coordinator 포함)
    ///
    /// - Important:
    ///   - 이 메서드는 매우 자주 호출될 수 있으므로 성능에 주의해야 합니다
    ///   - 불필요한 카메라 이동이나 마커 재생성을 방지하기 위해 상태 플래그를 사용합니다
    ///
    /// - Note: makeUIView보다 먼저 호출될 수 없으며, 뷰가 화면에 있는 동안 여러 번 호출됩니다
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
        
        coordinator.updateSelectedMarkerOptimized(
            selectedId: viewModel.selectedPlaceId,
            previousSelectedId: viewModel.getPreviousSelectedPlaceId())
    }
    
    /// Coordinator 생성
    func makeCoordinator() -> NaverMapViewCoordinator {
        NaverMapViewCoordinator(viewModel: viewModel)
    }
    
}
