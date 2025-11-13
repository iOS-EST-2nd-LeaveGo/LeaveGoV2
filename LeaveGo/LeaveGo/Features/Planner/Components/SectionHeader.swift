//
//  SectionHeader.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/17/25.
//

import SwiftUI

extension PlannerView {
    struct SectionHeader: View {
        let title: String
        
        var body: some View {
            Text(title)
                .padding(.leading, DesignToken.Spacing.small)
                .font(.footnote)
                .foregroundStyle(.lgLabelSecondary)
        }
    }
}
