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
    
    let contentType: ContentType
    let contentID: String
    
    init(contentType: ContentType, contentID: String) {
        self.contentType = contentType
        self.contentID = contentID
        
        var parameters = defaultParameters
        parameters["contentTypeId"] = contentType.rawValue
        parameters["contentId"] = contentID
        self.parameters = parameters
    }
}
