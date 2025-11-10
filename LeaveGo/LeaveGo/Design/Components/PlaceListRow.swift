//
//  PlaceListRow.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

/// 장소의 정보를 보여주는 Row입니다.
/// List로 감싸서 사용하시고
/// 호출 시 Row 바깥에서 listStyle과 buttonStyle을 .plain으로 설정하세요
struct PlaceListRow: View {
    @State var isSelected: Bool = false
    /// 표시할 장소 정보
    let place: PlaceDTO
    /// 리스트 행의 표시 모드
    let listMode: ListMode
    /// (옵셔널) 행이 탭되었을 때 실행할 액션 클로저
    let rowAction: (() -> Void)?
    /// (옵셔널) 액세서리가 탭되었을 때 실행할 액션 클로저
    let accessoryAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Button {
                // 선택 모드일 때 체크박스 이미지 상태 토글하기
                if listMode == .selectable {
                    isSelected.toggle()
                }
                
                // 행이 탭되었을 때 실행할 액션이 있다면 액션 실행하기
                if let rowAction {
                    rowAction()
                }
            } label: {
                HStack(spacing: DesignToken.Spacing.large) {
                    // 모드에 따른 행의 머리 이미지 보여주기
                    LeadingAccessory(listMode: listMode, isSelected: isSelected)
                    
                    PlaceholderImageView()
                    
                    VStack(alignment: .leading, spacing: DesignToken.Spacing.small) {
                        Text(CategoryCodeMapper.name(for: place.cat1 ?? "기타"))
                            .font(.caption)
                            .foregroundStyle(.lgLabelSecondary)
                        
                        Text(place.title)
                            .font(.headline)
                            .foregroundStyle(.lgLabel)
                    }
                    
                    Spacer()
                }
            }
            
            // 액세서리가 탭되었을 때 실행할 액션이 있다면 행의 꼬리 버튼 보여주기
            if let accessoryAction {
                TrailingAccessoryButton(listMode: listMode, accessoryAction: { accessoryAction() })
            }
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
    }
}

struct LeadingAccessory: View {
    let listMode: ListMode
    var isSelected: Bool = false
    
    var body: some View {
        switch listMode {
        case .plain:
            EmptyView()
        case .selectable:
            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 24)
                .foregroundStyle(.lgAccent)
        case .draggable:
            Image(systemName: "line.3.horizontal")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .foregroundStyle(.lgLabelSecondary)
        }
    }
}

struct TrailingAccessoryButton: View {
    let listMode: ListMode
    let accessoryAction: (() -> Void)
    
    var body: some View {
        Button {
            accessoryAction()
        } label: {
            Image(systemName: listMode == .plain ? "ellipsis" : "info.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 24)
                .foregroundStyle(.lgAccent)
        }
    }
}

#Preview {
    PlaceListRow(
        place: PlaceDTO(
            addr1: nil,
            addr2: nil,
            areaCode: nil,
            cat1: "A01",
            cat2: nil,
            cat3: nil,
            id: "11",
            contentTypeID: "11",
            dist: nil,
            bigThumbnailImage: nil,
            thumbnailImage: nil,
            mapX: nil,
            mapY: nil,
            tel: nil,
            title: "광화문"
        ),
        listMode: .selectable,
        rowAction: nil,
        accessoryAction: nil
    )
}
