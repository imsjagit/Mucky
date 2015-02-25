//
//  Device.swift
//  Mucki
//
//  Created by Hans Scheurlen on 13.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class Device: PFObject,PFSubclassing  {
    
    //////////////////////////////////
    // MARK: - Subclasing methods
    //////////////////////////////////
    
    override class func load() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "Device"
    }
    //////////////////////////////////
    // MARK: - Properties
    //////////////////////////////////
    var name:String {
        get { return self["name"] as String }
        set { self["name"] = newValue }
    }
    var propertyKeys:[String] {
        get {
            let value = self["propertyKeys"] as String
            return value.componentsSeparatedByString("@")
        }
    }
    var propertyLabels:[String] {
        get {
            let value = self["propertyLabels"] as String
            return value.componentsSeparatedByString("@")
        }
    }
}
