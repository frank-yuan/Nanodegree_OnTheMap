//
//  parseAPI.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/30/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class parseAPI: NSObject {
    
    struct ParseServiceConfig : ServiceConfig {
        var ApiScheme: String { return "https" }
        var ApiHost: String { return "api.parse.com" }
        var ApiPath: String { return "/1/classes/" }
    }
    
    static func getStudentsLocation(completeHandler:(result:AnyObject? , error:NetworkError) -> Void) {
        if let url = HttpServiceHelper.buildURL(ParseServiceConfig(), withPathExtension: "StudentLocation", queryItems: ["limit":100]) {
            let request = HttpRequest(url: url)
            request.addHeader([Constant.ParseApi.applicationIdKey: Constant.ParseApi.applicationIdValue,
                Constant.ParseApi.apiKeyKey: Constant.ParseApi.apiKeyValue])
            
            HttpService.service(request) { (data, error) in
                
                HttpServiceHelper.parseJSONResponse(data, error: error){ (result, networkError) in
                    completeHandler(result: result, error: networkError)
                }
            }
        }

    }
}
