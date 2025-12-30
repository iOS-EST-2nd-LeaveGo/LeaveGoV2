//
//  MapView.swift
//  LeaveGo
//
//  Created by 이치훈 on 9/21/25.
//

import SwiftUI

struct MapView: View {
    
    @State private var viewModel = MapViewModel()
    
    var body: some View {
        
        ZStack {
            NaverMapView()
                .environment(viewModel)
            
            // Map Launch Screen
            if !viewModel.isLocationLoaded {
                loadingOverlay
            }
        }
        .edgesIgnoringSafeArea(.vertical)
        .onChange(of: viewModel.isLocationLoaded) { _, newLocation in
            if newLocation && viewModel.userLocation != nil {
                Task {
                    await viewModel.fetchPlaceList()
                }
            }
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
}
