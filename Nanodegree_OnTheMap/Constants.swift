//
//  Constants.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/26/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//



struct Constant {
    
    struct ParseApi {
        static let applicationIdKey = "X-Parse-Application-Id"
        static let apiKeyKey = "X-Parse-REST-API-Key"
        static let applicationIdValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let apiKeyValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let contentTypeKey = "Content-Type"
        static let contentTypeValue = "application/json"
    }
    
    struct UdacityStudentKey {
        
        static let uniqueKey = "key"
        static let firstNameKey = "first_name"
        static let lastNameKey = "last_name"
    }
    
    struct ParseDataKey {
       static let uniqueKey  = "uniqueKey"
       static let firstName  = "firstName"
       static let lastName   = "lastName" 
       static let latitude   = "latitude" 
       static let longitude  = "longitude"
       static let mapString  = "mapString"
       static let mediaURL   = "mediaURL" 
    }   
    
    struct UserLocationDataKey {
        
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let mediaURL = "mediaURL"
            static let mapString = "mapString" 
            static let latitude = "latitude" 
            static let longitude = "longitude" 
    }
    
}