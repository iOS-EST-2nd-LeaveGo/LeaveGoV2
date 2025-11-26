//
//  MapView.swift
//  LeaveGo
//
//  Created by 이치훈 on 9/21/25.
//

import SwiftUI
import NMapsMap
import CoreLocation
import Combine

// MARK: - MapView
struct MapView: View {
    @Environment(MapViewModel.self) private var viewModel
    
    var body: some View {
        ZStack {
            NaverMapView()
                .environment(viewModel)
            
            if !viewModel.isLocationLoaded {
                Color("lgAccentColor")
                    .ignoresSafeArea()
                Image("img_logoWithNoBg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: min(max(UIScreen.main.bounds.width * 0.28, 90), 140),
                           height: min(max(UIScreen.main.bounds.width * 0.28, 90), 140))
                    .colorScheme(.light)
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .task {
            await viewModel.fetchPlaceList()
        }
        .alert("위치 오류", isPresented: Binding(
            get: { viewModel.showLocationError },
            set: { viewModel.showLocationError = $0 }
        )) {
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
}

// MARK: - NaverMapView
struct NaverMapView: UIViewRepresentable {
    
    @Environment(MapViewModel.self) private var viewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 15
        
        view.mapView.isIndoorMapEnabled = true
        
        view.showLocationButton = true
        view.showCompass = true
        
        /// 사용자 위치 annotation layout
        let locationOverlay = view.mapView.locationOverlay
        locationOverlay.icon = NMFOverlayImage(name: "img_userLocation")
        locationOverlay.iconWidth = 25
        locationOverlay.iconHeight = 25
        locationOverlay.anchor = CGPoint(x: 0, y: 0)
        locationOverlay.circleRadius = 0
        
        /// 미리 NaverMap을 Loading하기 위한 임시 Location
        let defaultCoord = NMGLatLng(lat: 37.5665, lng: 126.9780)
        let cameraPosition = NMFCameraPosition(defaultCoord, zoom: 15)
        view.mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        guard let location = viewModel.userLocation else { return }
        
        let nmgCoord = NMGLatLng(lat: location.latitude,
                                 lng: location.longitude)
        let cameraUpdate = NMFCameraUpdate(scrollTo: nmgCoord)
        
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.5
        uiView.mapView.moveCamera(cameraUpdate)
    }
}

// MARK: - Coordinator
class Coordinator: NSObject, NMFMapViewCameraDelegate {
    var parent: NaverMapView
    
    init(parent: NaverMapView) {
        self.parent = parent
    }
    
    func mapViewDidFinishLoadingMap() {
        print("지도 로딩 완료")
    }
    
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        print("📷 카메라 변경: reason=\(reason), animated=\(animated)")
    }
}

#Preview {
    MapView()
}
