//
//  AreaBasedEndpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/1/25.
//

import Foundation

struct AreaBasedEndpoint: Endpoint {
    var apiType: APIType = .tour
    let path: String = "/areaBasedSyncList2"
    let method: HTTPMethod = .get
    var parameters: [String : Any]?
    
    let contentType: ContentType = .touristAttraction
    let page: Int
    let numOfRows: Int
    let area: Area
    
    init(page: Int, numOfRows: Int, area: Area) {
        self.page = page
        self.numOfRows = numOfRows
        self.area = area
        
        var parameters = defaultParameters
        parameters["pageNo"] = page
        parameters["numOfRows"] = numOfRows
        parameters["areaCode"] = area.code
        parameters["contentTypeId"] = contentType.rawValue
        self.parameters = parameters
    }
}
