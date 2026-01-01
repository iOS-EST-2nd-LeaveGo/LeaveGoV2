//
//  CLLocation+Extension.swift
//  LeaveGo
//
//  Created by 이치훈 on 1/1/26.
//

import CoreLocation

// CLLocationCoordinate2D를 Equatable로 확장 (카메라 위치 비교용)
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
