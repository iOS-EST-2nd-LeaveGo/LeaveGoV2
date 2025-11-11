//
//  PlaceDetailSheetView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/11/25.
//

import SwiftUI

struct PlaceDetailSheetView: View {
    let place: PlaceDTO
    let buttonTitle: String
    
    @State private var detailInfo: PlaceDetailDTO? = nil
    @State private var isLoading: Bool = false
    
    private var contentType: ContentType {
        switch place.contentTypeID {
        case "12": return .touristAttraction
        case "14": return .cultureFacility
        case "28": return .leisureSports
        case "38": return .shopping
        case "39": return .restaurant
        default: return .touristAttraction
        }
    }
    
    var placeholderTextView: some View {
        Text("로딩 중..")
            .font(.footnote)
            .foregroundStyle(.lgLabelSecondary)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignToken.Spacing.medium) {
                    HStack {
                        Text(place.title)
                            .font(.title3)
                            .bold()
                        
                        Spacer()
                    }
                    
                    Group {
                        HStack(alignment: .top, spacing: DesignToken.Spacing.medium) {
                            Text("휴무일")
                            Text("|")
                            if let restDate = detailInfo?.restDate, !restDate.isEmpty {
                                Text(restDate)
                            } else if isLoading {
                                placeholderTextView
                            } else {
                                Text("정보 없음")
                                
                            }
                        }
                        
                        HStack(alignment: .top, spacing: DesignToken.Spacing.medium) {
                            Text("운영시간")
                            Text("|")
                            if let openTime = detailInfo?.openTime, !openTime.isEmpty {
                                Text(openTime)
                            } else if isLoading {
                                placeholderTextView
                            } else {
                                Text("정보 없음")
                            }
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.lgLabelSecondary)
                    
                    if let addr1 = place.addr1, !addr1.isEmpty {
                        Text(place.addr1!)
                        + Text(" \(place.addr2 ?? "")")
                    }
                    
                    if let tel = place.tel, !tel.isEmpty {
                        Text(tel)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .frame(maxHeight: .infinity)
            
            BottomActionButton(title: buttonTitle, imageName: "arrow.trianglehead.turn.up.right.circle.fill", isEnabled: true) {
                // TODO: 경로 찾기 기능 완성되면 액션 추가하기
            }
        }
        .task {
            // View가 열릴 때 Detail 정보 가져오기
            await loadDetail()
        }
    }
}

extension PlaceDetailSheetView {
    private func loadDetail() async {
        do {
            isLoading = true
            detailInfo = try await PlaceRepository().fetchPlaceDetail(
                endpoint: PlaceDetailEndpoint(
                    contentType: contentType,
                    contentID: place.id
                )
            )
            isLoading = false
        } catch {
            print("🔥 \(place.title) 상세 정보 가져오기 실패")
        }
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.black.opacity(0.1)
        
        PlaceDetailSheetView(
            place: PlaceDTO(
                addr1: Optional("대구광역시 동구 각산동"),
                addr2: Optional("134"),
                areaCode: Optional("4"),
                cat1: Optional("A01"),
                cat2: Optional("A0101"),
                cat3: Optional("A01010500"),
                id: "2667909",
                contentTypeID: "12",
                dist: nil,
                bigThumbnailImage: Optional(""),
                thumbnailImage: Optional(""),
                mapX: Optional("128.7199264348"),
                mapY: Optional("35.8799433837"),
                tel: Optional(""),
                title: "나불지 생태공원"
            ),
            buttonTitle: "경로 찾기"
        )
        .frame(height: 400)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
