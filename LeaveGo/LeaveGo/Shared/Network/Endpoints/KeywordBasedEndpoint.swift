//
//  KeywordBasedEndpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/1/25.
//

import Foundation

struct KeywordBasedEndpoint: Endpoint {
    var apiType: APIType = .tour
    let path: String = "/searchKeyword2"
    let method: HTTPMethod = .get
    var parameters: [String : Any]?
    
    let page: Int
    let numOfRows: Int
    let keyword: String
    
    init(page: Int, numOfRows: Int, keyword: String) {
        self.page = page
        self.numOfRows = numOfRows
        self.keyword = keyword
        
        var parameters = defaultParameters
        parameters["pageNo"] = page
        parameters["numOfRows"] = numOfRows
        parameters["keyword"] = keyword
        self.parameters = parameters
    }
}
