//
//  Property.swift
//  Mucki
//
//  Created by Hans Scheurlen on 16.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class Property: PFObject,PFSubclassing  {
    
    //////////////////////////////////
    // MARK: - Subclassing methods
    //////////////////////////////////
    
    override class func load() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "Property"
    }
    
    //////////////////////////////////
    // MARK: - Properties
    //////////////////////////////////
    var key:String {
        get { return self["key"] as String }
        set { self["key"] = newValue }
    }
    var value:Double {
        get { return self["value"] as Double }
        set { self["value"] = newValue }
    }
}
