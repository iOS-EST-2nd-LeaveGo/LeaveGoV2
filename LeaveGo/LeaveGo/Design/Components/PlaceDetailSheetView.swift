//
//  PlaceDetailSheetView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/11/25.
//

import SwiftUI

/// 여행지 상세정보를 표시하는 시트 뷰
struct PlaceDetailSheetView: View {
    /// 표시할 여행지 정보
    let place: PlaceDTO
    /// 하단 액션 버튼의 제목
    let buttonTitle: String

    /// 여행지 상세 정보 (API로부터 가져옴)
    @State private var detailInfo: PlaceDetailDTO? = nil
    /// 데이터 로딩 상태
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 메인 콘텐츠 스크롤 영역
            ScrollView {
                VStack(alignment: .leading, spacing: DesignToken.Spacing.medium) {
                    // 여행지 제목
                    HStack {
                        Text(place.title)
                            .font(.title3)
                            .bold()

                        Spacer()
                    }

                    // 상세 정보 행들
                    DetailLabelRow(isLoading: $isLoading, label: "휴무일", value: detailInfo?.restDate)
                    DetailLabelRow(isLoading: $isLoading, label: "운영시간", value: detailInfo?.openTime)

                    // 주소 정보
                    if let addr1 = place.addr1, !addr1.isEmpty {
                        Text("\(addr1) \(place.addr2 ?? "")")
                    }

                    // 전화번호
                    if let tel = place.tel, !tel.isEmpty {
                        if let url = URL(string: "tel://\(tel)") {
                            Link(tel, destination: url)
                        } else {
                            Text(tel)
                        }
                    }

                    Spacer()
                }
            }
            .padding()
            .frame(maxHeight: .infinity)

            // 하단 액션 버튼
            BottomActionButton(title: buttonTitle, imageName: "arrow.trianglehead.turn.up.right.circle.fill", isEnabled: true) {
                // TODO: 경로 찾기 기능 완성되면 액션 추가하기
            }
        }
        .task(id: place.id) {
            // View가 열릴 때 Detail 정보 가져오기
            await loadDetail()
        }
    }
    
    /// 상세 정보 레이블과 값을 표시하는 행 컴포넌트
    private struct DetailLabelRow: View {
        /// 로딩 상태 바인딩
        @Binding var isLoading: Bool

        /// 레이블 텍스트
        let label: String
        /// 표시할 값 (nil일 수 있음)
        let value: String?

        /// 상세 정보 가져오기 상태
        private enum DetailFetchStatus: String {
            case noData = "정보 없음"
            case loading = "로딩 중.."
        }

        /// 플레이스홀더 텍스트 뷰 생성
        private func placeholderTextView(status: DetailFetchStatus) -> some View {
            Text(status.rawValue)
                .font(.footnote)
                .foregroundStyle(.lgLabelSecondary)
        }

        var body: some View {
            HStack(alignment: .top, spacing: DesignToken.Spacing.medium) {
                // 레이블 (태그 스타일)
                Text(label)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .background(.lgBackgroundAccentLight)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .foregroundStyle(.lgAccent)
                
                // 값 또는 플레이스홀더
                Group {
                    if let value = value, !value.isEmpty {
                        Text(value)
                            .foregroundStyle(.lgLabel)
                    } else if isLoading {
                        placeholderTextView(status: .loading)
                    } else {
                        placeholderTextView(status: .noData)
                    }
                }
                .padding(.vertical, 4)
                .foregroundStyle(.lgLabelSecondary)
            }
            .font(.footnote)
        }
    }
}

extension PlaceDetailSheetView {
    /// 여행지 상세 정보를 API로부터 가져오는 함수
    @MainActor
    private func loadDetail() async {
        defer { isLoading = false }
        
        do {
            guard let contentType = place.contentTypeID.toContentID() else {
                print(#function, "🔥 사용하지 않는 contentTypeID: \(place.contentTypeID)")
                return
            }
            isLoading = true
            
            // PlaceRepository를 통해 장소의 상세 정보 요청
            detailInfo = try await PlaceRepository().fetchPlaceDetail(
                endpoint: PlaceDetailEndpoint(
                    contentType: contentType,
                    contentID: place.id
                )
            )
        } catch {
            // 에러 발생 시 콘솔에 로그 출력
            print(#function, "🔥 \(place.title) 상세 정보 가져오기 실패")
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
