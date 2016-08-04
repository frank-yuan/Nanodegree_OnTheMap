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

class ResourceHandler<T> : NSObject {
    private let sender : T
    private let releaseHandler : (T) -> Void
    
    init(sender: T, onReleaseHandler: (T) -> Void) {
        self.sender = sender
        releaseHandler = onReleaseHandler
    }
    
    init (onStartHandler: () -> T, onReleaseHandler:(T) -> Void) {
        sender = onStartHandler()
        releaseHandler = onReleaseHandler
    }
    
    deinit {
        releaseHandler(sender)
    }
}

class AutoSelectorCaller : NSObject{
    
    private let sender: AnyObject
    private let releaseSelector : Selector
    
    init(sender: AnyObject, releaseSelector: Selector) {
        self.sender = sender
        self.releaseSelector = releaseSelector
    }
    
    init(sender: AnyObject, startSelector: Selector, releaseSelector: Selector) {
        self.sender = sender
        self.releaseSelector = releaseSelector
        sender.performSelectorOnMainThread(startSelector, withObject: nil, waitUntilDone: false)
    }
    
    deinit {
        sender.performSelectorOnMainThread(releaseSelector, withObject: nil, waitUntilDone: false)
    }
}
