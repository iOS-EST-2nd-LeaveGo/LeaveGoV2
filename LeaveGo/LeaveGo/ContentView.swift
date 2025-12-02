//
//  ContentView.swift
//  LeaveGo
//
//  Created by 박동언 on 9/4/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State private var mapViewModel = MapViewModel()
    
    var body: some View {
        TabView {
            DummyView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
            
            MapView()
                .environment(mapViewModel)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("장소")
                }
            
            PlannerView()
                .tabItem {
                    Image(systemName: "hat.widebrim.fill")
                    Text("여행")
                }
            
            DummyView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("마이페이지")
                }
        }
    }
}

/* 탭 만들기 위한 임시 뷰! 마지막으로 바꾸시는 분이 지우기 */
struct DummyView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Home")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
