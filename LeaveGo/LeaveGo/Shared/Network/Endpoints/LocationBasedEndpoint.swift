//
//  LocationBasedEndpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/30/25.
//

import Foundation

struct LocationBasedEndpoint: Endpoint {
    var apiType: APIType = .tour
    let path: String = "locationBasedList2"
    let method: HTTPMethod = .get
    var parameters: [String : Any]?
    
    let page: Int
    let numOfRows: Int
    let mapX: Double
    let mapY: Double
    let radius: Int
    let contentType: ContentType
    let arrange: String
    
    init(page: Int, numOfRows: Int, mapX: Double, mapY: Double, radius: Int, contentType: ContentType, arrange: String) {
        self.page = page
        self.numOfRows = numOfRows
        self.mapX = mapX
        self.mapY = mapY
        self.radius = radius
        self.contentType = contentType
        self.arrange = arrange
        
        var parameters = defaultParameters
        parameters["pageNo"] = page
        parameters["numOfRows"] = numOfRows
        parameters["mapX"] = mapX
        parameters["mapY"] = mapY
        parameters["radius"] = radius
        parameters["contentTypeId"] = contentType.rawValue
        parameters["arrange"] = arrange
        self.parameters = parameters
    }
}

