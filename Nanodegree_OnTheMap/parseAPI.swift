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
    
    static func getStudentLocation(uniqueKey:String, completeHandler:(result:AnyObject? , error:NetworkError) -> Void) {
        let parameter = "{\"uniqueKey\":\"\(uniqueKey)\"}".stringByAddingPercentEscapesUsingEncoding(NSUnicodeStringEncoding)
        if let url = HttpServiceHelper.buildURL(ParseServiceConfig(), withPathExtension: "StudentLocation", queryItems: ["where":parameter!]) {
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
    
    static func postStudentLocation(userId:String, userData:UserLocationData.UserData, completeHandler:(result:AnyObject? , error:NetworkError) -> Void) {
        if let url = HttpServiceHelper.buildURL(ParseServiceConfig(), withPathExtension: "StudentLocation", queryItems: nil) {
            let request = HttpRequest(url: url, method: HttpRequest.HttpMethod.POST)
            request.addHeader([Constant.ParseApi.applicationIdKey: Constant.ParseApi.applicationIdValue,
                Constant.ParseApi.apiKeyKey: Constant.ParseApi.apiKeyValue])
            request.addData("uniqueKey", value: userId)
            request.addData("firstName", value: userData.firstName)
            request.addData("lastName", value: userData.lastName)
            request.addData("mediaURL", value: userData.mediaURL)
            request.addData("mapString", value: userData.mapString)
            request.addData("latitude", value: userData.latitude)
            request.addData("longitude", value: userData.longitude)
            
            HttpService.service(request) { (data, error) in
                HttpServiceHelper.parseJSONResponse(data, error: error){ (result, networkError) in
                    completeHandler(result: result, error: networkError)
                }
            }
        }
    }

}
