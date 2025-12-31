//
//  PlaceMarker.swift
//  LeaveGo
//
//  Created by 이치훈 on 12/30/25.
//

import SwiftUI

struct PlaceMarkerView: View {
    
    let isSelected: Bool
    
    init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.red.opacity(0.3))
            
            Circle()
                .fill(isSelected ? .lgAccent : .lgBackgroundAccent)
                .frame(width: isSelected ? 48 : 40,
                       height: isSelected ? 48 : 40)
                .shadow(.medium)
            
            Image(systemName: "house.fill")
        }
    }
}
