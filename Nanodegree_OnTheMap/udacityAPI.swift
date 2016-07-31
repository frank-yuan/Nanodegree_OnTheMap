//
//  udacityAPI.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/30/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit



class udacityAPI: NSObject {
    
    struct UdacityServiceConfig : ServiceConfig {
        var ApiScheme: String { return "https" }
        var ApiHost: String { return "www.udacity.com" }
        var ApiPath: String { return "/api/" }
    }
    
    static func authenticate(email:String, password:String, completionHandler:(result:AnyObject? , error:NetworkError) -> Void) {
        if let url = HttpServiceHelper.buildURL(UdacityServiceConfig(), withPathExtension: "session", queryItems: nil) {
            
            let request = HttpRequest(url: url, method: .POST)
            
            request.addHeader(["Accept":"application/json", "Content-Type":"application/json" ])
            request.addData("udacity", value: ["username":email, "password":password])
            
            HttpService.service(request) { (data, error) in
                // Move five character ahead
                if let data = data where error == NetworkError.NoError{
                    let data = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                    HttpServiceHelper.parseJSONResponse(data, error: error) { (result, error) in
                        completionHandler(result:result, error:error)
                    }
                } else {
                    completionHandler(result:data, error:error)
                }
            }
        }
    }
    
    static func logout(completionHandler:(result: AnyObject?, error: NetworkError)->Void) {
        if let url = HttpServiceHelper.buildURL(UdacityServiceConfig(), withPathExtension: "session", queryItems: nil) {
            let request = HttpRequest(url: url, method: .DELETE)
            

            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.addHeader(["X-XSRF-TOKEN":xsrfCookie.value])
            }
            
            HttpService.service(request) { (data, error) in
                completionHandler(result: data, error: error)
            }
        }
    }
    
    static func getUserData(userId:String, completionHandler:(result: AnyObject?, error: NetworkError)->Void) {
        if let url = HttpServiceHelper.buildURL(UdacityServiceConfig(), withPathExtension: "users/\(userId)", queryItems: nil) {
            let request = HttpRequest(url: url)
            HttpService.service(request) { (data, error) in
                if let data = data where error == NetworkError.NoError{
                    let data = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                    HttpServiceHelper.parseJSONResponse(data, error: error) { (result, error) in
                        completionHandler(result:result, error:error)
                    }
                } else {
                    completionHandler(result:data, error:error)
                }
            }
        }
    }
}
