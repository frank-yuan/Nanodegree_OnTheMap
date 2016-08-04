//
//  parseAPI.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/30/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import Foundation

class parseAPI: NSObject {
    static let queryLimit = 100
    struct ParseServiceConfig : ServiceConfig {
        var ApiScheme: String { return "https" }
        var ApiHost: String { return "parse.udacity.com" }
        var ApiPath: String { return "/parse/classes/" }
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
    
    static func getStudentLocation(uniqueKey:String, completeHandler:(result:AnyObject? , error:NetworkError) -> Void) {
        let parameter = "{\"uniqueKey\":\"\(uniqueKey)\"}"
        if let url = HttpServiceHelper.buildURL(ParseServiceConfig(), withPathExtension: "StudentLocation", queryItems: ["where":parameter]) {
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
    
    static func postStudentLocation(data:[String:AnyObject], objectId:String = "", completeHandler:(result:AnyObject? , error:NetworkError) -> Void) {
        
        let isUpdate:Bool = objectId != ""
        
        if let url = HttpServiceHelper.buildURL(ParseServiceConfig(), withPathExtension: "StudentLocation" + (isUpdate ? "/\(objectId)" : ""), queryItems: nil) {
            let request = HttpRequest(url: url, method: (isUpdate ? HttpRequest.HttpMethod.PUT : HttpRequest.HttpMethod.POST))
            request.addHeader([
                Constant.ParseApi.applicationIdKey: Constant.ParseApi.applicationIdValue,
                Constant.ParseApi.apiKeyKey:        Constant.ParseApi.apiKeyValue,
                Constant.ParseApi.contentTypeKey:   Constant.ParseApi.contentTypeValue])
            
            for (key, value) in data {
                request.addData(key, value: value)
            }
            
            HttpService.service(request) { (data, error) in
                HttpServiceHelper.parseJSONResponse(data, error: error){ (result, networkError) in
                    completeHandler(result: result, error: networkError)
                }
            }
        }
    }

}
