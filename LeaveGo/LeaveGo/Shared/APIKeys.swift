//
//  APIKeys.swift
//  LeaveGo
//
//  Created by 이치훈 on 9/21/25.
//

import Foundation

struct APIKeys {
    static var naverMapClientId: String {
        if let clientId = Bundle.main.object(forInfoDictionaryKey: "NMFClientId") as? String, !clientId.isEmpty,
           clientId != "NAVER_MAP_CLIENT_ID" {
            return clientId
        }
        
        #if DEBUG
        return ""
        #else
        fatalError("Production build requires proper configuration")
        #endif
    }
}
