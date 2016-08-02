//
//  AnyObjectHelper.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 8/2/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class AnyObjectHelper{
    static func parseData<T>(object:AnyObject?, name:String, defaultValue:T) -> T {
        if let object = object, result = object[name] as? T {
            return result
        }
        return defaultValue
    }
}
