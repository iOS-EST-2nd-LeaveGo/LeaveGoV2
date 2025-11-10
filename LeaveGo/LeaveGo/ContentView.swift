//
//  ContentView.swift
//  LeaveGo
//
//  Created by 박동언 on 9/4/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            DummyView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
            
            MapView()
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
        .task {
            Task {
                let repository = PlaceRepository()
                do {
                    if let data = try await repository.fetchPlaceList(with: KeywordBasedEndpoint(page: 1, numOfRows: 2, keyword: "광화문")) {
                        print("▶️ 장소 리스트 가져오기")
                        print("🔥 전체 결과 \(data.totalCount)개")
                        print("🔥 장소 목록 :", data.placeList)
                        print("")
                    }
                    
                    if let data = try await repository.fetchPlaceDetail(with: PlaceDetailEndpoint(contentType: .cultureFacility, contentID: "130821")) {
                        print("▶️ 장소 상세 정보 가져오기")
                        print("🔥 장소 상세 :", data)
                    }
                } catch {
                    print(error)
                }
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
