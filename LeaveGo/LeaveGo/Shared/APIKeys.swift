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
        print("⚠️ [APIKeys] Naver Map Client ID not found or not configured")
        print("   [APIKeys] Please check:")
        print("   1. Secrets.xcconfig file exists")
        print("   2. Configuration is properly linked")
        print("   3. Info.plist contains NMFClientId key")
        return ""
#else
        print("❌ [Production] Naver Map Client ID not configured")
        print("   [Production] Check configuration files and rebuild")
        return ""
#endif
    }
    
    static var tourAPI: String? {
        if let key = Bundle.main.object(forInfoDictionaryKey: "TourAPIServiceKey") as? String, !key.isEmpty,
           key != "TOUR_API_SERVICE_KEY" {
            return key
        }
        return nil
    }
}
