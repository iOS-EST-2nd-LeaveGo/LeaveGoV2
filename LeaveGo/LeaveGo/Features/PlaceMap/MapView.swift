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

    @State private var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var isLocationLoaded = false
    @State private var showLocationError = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ZStack {
            NaverMapView(coord: userLocation,
                         isLoacationLoaded: $isLocationLoaded)
            
            if !isLocationLoaded {
                Rectangle()
                    .fill(Color("lgAccentColor"))
                
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
            requestUserLocation()
        }
        .alert("위치 오류", isPresented: $showLocationError) {
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    @MainActor
    private func requestUserLocation() {
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
}

// MARK: - NaverMapView
struct NaverMapView: UIViewRepresentable {
    var coord: CLLocationCoordinate2D
    @Binding var isLoacationLoaded: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 17
        
        view.mapView.isIndoorMapEnabled = true
        
        view.showLocationButton = true
        view.showCompass = true
        
        let cameraPosition = NMFCameraPosition(NMGLatLng(lat: coord.latitude,
                                                         lng: coord.longitude),
                                               zoom: 17)
        
        view.mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        let nmgCoord = NMGLatLng(lat: coord.latitude,
                                 lng: coord.longitude)
        let cameraUpdate = NMFCameraUpdate(scrollTo: nmgCoord)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.5
        
        uiView.mapView.moveCamera(cameraUpdate)
        
        context.coordinator.updateUserLocationMarker(on: uiView.mapView,
                                                     at: nmgCoord)
    }
}

// MARK: - Coordinator
class Coordinator: NSObject, NMFMapViewCameraDelegate {
    var parent: NaverMapView
    var userLocationMarker: NMFMarker?
    
    init(parent: NaverMapView) {
        self.parent = parent
    }
    
    func updateUserLocationMarker(on mapView: NMFMapView, at coord: NMGLatLng) {
        if let existingMarker = userLocationMarker {
            existingMarker.mapView = nil
        }
        
        let marker = NMFMarker()
        marker.position = coord
        marker.mapView = mapView
        
        marker.iconImage = NMFOverlayImage(name: "img_userAnnotation")
        
        marker.width = 25
        marker.height = 25*1.44
        marker.anchor = CGPoint(x: 0.5, y: 0.63)
        marker.iconTintColor = UIColor.systemBlue
        
        userLocationMarker = marker
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
