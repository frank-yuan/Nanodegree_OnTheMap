//
//  UserLocationData.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/28/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//
import UIKit

struct UserLocationData {
    struct UserData {
        let firstName:String
        let lastName:String
        let mediaURL:String
        let mapString:String
        let latitude:Double
        let longitude:Double
        init(object:AnyObject) {
            firstName = AnyObjectHelper.parseData(object, name: Constant.UserLocationDataKey.firstName, defaultValue: "")
            lastName = AnyObjectHelper.parseData(object, name: Constant.UserLocationDataKey.lastName, defaultValue: "")
            mediaURL = AnyObjectHelper.parseData(object, name: Constant.UserLocationDataKey.mediaURL, defaultValue: "")
            mapString = AnyObjectHelper.parseData(object, name: Constant.UserLocationDataKey.mapString, defaultValue: "")
            latitude = AnyObjectHelper.parseData(object, name: Constant.UserLocationDataKey.latitude, defaultValue: 0.0)
            longitude = AnyObjectHelper.parseData(object, name: Constant.UserLocationDataKey.longitude, defaultValue: 0.0)
        }
    }
    
    var userId : String
    var locations: [UserData]
    
    
    private static var sharedData : UserLocationData = UserLocationData(userId: "",locations: [UserData]())
    
    static func getInstance() -> UserLocationData{
        return sharedData
    }
    
    static func reset() {
        sharedData.userId = ""
        sharedData.locations.removeAll()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userId")
    }
    
    static func setUserId(uid:String) {
        sharedData.userId = uid
    }
    
    static func appendLocation(location:UserData) {
        sharedData.locations.append(location)
    }
    
    static func clearLocation() {
        sharedData.locations.removeAll()
    }
}
