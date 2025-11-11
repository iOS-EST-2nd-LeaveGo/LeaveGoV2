//
//  SectionButtonLabel.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/17/25.
//

import SwiftUI

extension PlannerView {
    struct SectionButtonLabel: View {
        let title: String
        
        var body: some View {
            Text(title)
                .foregroundStyle(.lgAccent)
                .font(.footnote)
        }
    }
}
