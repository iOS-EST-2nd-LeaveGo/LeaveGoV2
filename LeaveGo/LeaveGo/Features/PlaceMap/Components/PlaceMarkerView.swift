//
//  PlaceMarker.swift
//  LeaveGo
//
//  Created by 이치훈 on 12/30/25.
//

import SwiftUI

struct PlaceMarkerView: View {
    
    let isSelected: Bool
    let thumbnail: UIImage?
    
    init(isSelected: Bool = false, thumbnail: UIImage? = nil) {
        self.isSelected = isSelected
        self.thumbnail = thumbnail
    }
    
    var body: some View {
        ZStack {
#if DEBUG
            Rectangle()
                .fill(.red.opacity(0.3))
#endif
            
            Circle()
                .fill(isSelected ? .lgAccent : .lgBackgroundAccent)
                .frame(width: isSelected ? 48 : 40,
                       height: isSelected ? 48 : 40)
                .shadow(.medium)
            
            if let thumbnail {
                thumbnailImage(Image(uiImage: thumbnail))
            } else {
                Circle()
                    .fill(isSelected ? .lgSubAccent : .clear)
                    .frame(width: 40,
                           height: 40)
                
                thumbnailImage(Image("img_logoWithNoBg"))
            }
        }
    }
    
    @ViewBuilder
    private func thumbnailImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: isSelected ? 40 : 32,
                   height: isSelected ? 40 : 32)
            .clipShape(Circle())
    }
}
