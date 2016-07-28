//
//  HttpEndPoint.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/26/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit


enum NetworkError : Int {
    case NoError = 0,
    RequestError,
    ResponseWrongStatus,
    NoData,
    ParseJSONError,
    ParseHttpBodyError
}

protocol EndPointConfig {
    var ApiScheme: String { get }
    var ApiHost: String { get }
    var ApiPath: String { get }
}

class HttpEndPoint : NSObject {
    
    private let config:EndPointConfig
    
    init(config:EndPointConfig) {
        self.config = config
    }

    static func responseAdapterJSON(data:NSData?, error:NetworkError?, completeHandler:(AnyObject?, NetworkError?) -> Void) -> Void {
        if (error == NetworkError.NoError) {
            /* Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                performUIUpdatesOnMain {
                    completeHandler(nil, NetworkError.ParseJSONError)
                }
                return
            }
            
            performUIUpdatesOnMain {
                completeHandler(parsedResult, error)
            }
            
        } else {
            performUIUpdatesOnMain {
                completeHandler(data, error)
            }
        }
    }
    
    
    func get(parameters:[String:AnyObject], withPathExtension: String? = nil, withHeaderParams:[String:String]? = nil, completeHandler:(NSData?, NetworkError) -> Void) -> Void {

        
        if let url = buildURL(parameters, withPathExtension: withPathExtension) {
            let request = NSMutableURLRequest(URL: url)
            if let withHeaderParams = withHeaderParams {
                for headerEntry in withHeaderParams {
                    request.addValue(headerEntry.1, forHTTPHeaderField: headerEntry.0)
                }
            }
            
            performRequest(request, completeHandler:completeHandler)
        }
    }
    
    func post(withHttpBody: AnyObject? = nil, withPathExtension: String? = nil, withHeaderParams:[String:String]? = nil, completeHandler:(NSData?, NetworkError) -> Void) -> Void {
        
        if let url = buildURL(nil, withPathExtension: withPathExtension) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            if let withHeaderParams = withHeaderParams {
                for headerEntry in withHeaderParams {
                    request.addValue(headerEntry.1, forHTTPHeaderField: headerEntry.0)
                }
            }
            if let withHttpBody = withHttpBody {
                do {
                    let httpBody = try NSJSONSerialization.dataWithJSONObject(withHttpBody, options: NSJSONWritingOptions.PrettyPrinted)
                    request.HTTPBody = httpBody
                    // here "jsonData" is the dictionary encoded in JSON data
                } catch {
                    completeHandler(nil, NetworkError.ParseHttpBodyError)
                    return
                }
            }
            performRequest(request, completeHandler:completeHandler)
        }
    }
    
    private func buildURL(parameters:[String:AnyObject]?, withPathExtension: String? = nil) -> NSURL? {
        let components = NSURLComponents()
        components.scheme = config.ApiScheme
        components.host = config.ApiHost
        components.path = config.ApiPath + (withPathExtension ?? "")
        
        if components.path?.characters.first != "/"{
            components.path?.insert("/", atIndex: (components.path?.startIndex)!)
        }
        
        if let parameters = parameters where parameters.count > 0 {
            components.queryItems = [NSURLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.URL
    }
    
    private func performRequest(request:NSURLRequest, completeHandler:(NSData?, NetworkError) -> Void) -> Void {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                performUIUpdatesOnMain {
                    completeHandler(nil, NetworkError.RequestError)
                }
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                performUIUpdatesOnMain {
                    completeHandler(data, NetworkError.ResponseWrongStatus)
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                performUIUpdatesOnMain {
                    completeHandler(nil, NetworkError.NoData)
                }
                return
            }
            
            performUIUpdatesOnMain {
                completeHandler(data, NetworkError.NoError)
            }
        }
        task.resume()
    }
}
