//
//  AppEndPointConfig.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/27/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

struct UdacityServiceConfig : ServiceConfig {
    var ApiScheme: String { return "https" }
    var ApiHost: String { return "www.udacity.com" }
    var ApiPath: String { return "/api/" }
}

struct ParseServiceConfig : ServiceConfig {
    var ApiScheme: String { return "https" }
    var ApiHost: String { return "api.parse.com" }
    var ApiPath: String { return "/1/classes/" }
}