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
    
    func makeCoordinator() -> NaverMapViewCoordinator {
        NaverMapViewCoordinator(viewModel: viewModel)
    }
    
}
