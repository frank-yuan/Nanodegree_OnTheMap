//
//  UserLocationData.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/28/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

struct UserLocationData {
    struct UserLocation {
        let name:String
        let url:String
        let latitude:CGFloat
        let longitude:CGFloat
    }
    
    var userId : String
    var locations: [UserLocation]
    
    
    private static var sharedData : UserLocationData = UserLocationData(userId: "", locations: [UserLocation]())
    
    static func getInstance() -> UserLocationData{
        return sharedData
    }
    
    static func reset() {
        sharedData.userId = ""
        sharedData.locations.removeAll()
    }
    
    static func setUserId(uid:String) {
        sharedData.userId = uid
    }
    
    static func appendLocation(location:UserLocation) {
        sharedData.locations.append(location)
    }
}
