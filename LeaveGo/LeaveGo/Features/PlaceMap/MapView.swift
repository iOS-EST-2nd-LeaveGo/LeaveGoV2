//
//  MapView.swift
//  LeaveGo
//
//  Created by 이치훈 on 9/21/25.
//

import SwiftUI
import NMapsMap

struct MapView: View {
    var body: some View {
        ZStack {
            NaverMapView(coord: (127.269311, 37.413294))
                .edgesIgnoringSafeArea(.vertical)
        }
    }
}

struct NaverMapView: UIViewRepresentable {
    var coord: (Double, Double)
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 17
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        let coord = NMGLatLng(lat: coord.1, lng: coord.0)
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 1
        uiView.mapView.moveCamera(cameraUpdate)
    }
}

#Preview {
    MapView()
}
