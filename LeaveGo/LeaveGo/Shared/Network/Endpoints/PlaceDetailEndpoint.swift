//
//  PlaceDetailEndpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/30/25.
//

import Foundation

struct PlaceDetailEndpoint: Endpoint {
    var apiType: APIType = .tour
    let path: String = "/detailIntro2"
    let method: HTTPMethod = .get
    var parameters: [String : Any]?
    
    let contentTypeId: String
    let contentId: String
    
    init(contentTypeId: String, contentId: String) {
        self.contentTypeId = contentTypeId
        self.contentId = contentId
        
        var parameters = defaultParameters
        parameters["contentTypeId"] = contentTypeId
        parameters["contentId"] = contentId
        self.parameters = parameters
    }
}
