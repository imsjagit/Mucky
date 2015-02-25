    //
//  Exercise.swift
//  Mucki
//
//  Created by Hans Scheurlen on 13.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class Exercise: PFObject,PFSubclassing  {
    
    
    //////////////////////////////////
    // MARK: - Subclassing methods
    //////////////////////////////////
    
    override class func load() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "Exercise"
    }
    
    //////////////////////////////////
    // MARK: - Properties
    //////////////////////////////////
    var name:String {
        get { return self["name"] as String }
        set { self["name"] = newValue }
    }
    var device:Device {
        get {
            return self["device"] as Device
        }
        set { self["device"] = newValue }
    }
    var properties:[Property] {
        get {
            var result:[Property]
            if self.objectForKey("properties") != nil{
                result = self["properties"] as [Property]
            }else{
                result = [Property]()
            }
            return result
        }
        set { self["properties"] = newValue }
    }
    
    func loadProperties() ->[Property]{
        var result:[Property]?
        var query = PFQuery(className: "Exercise")
        query.fromLocalDatastore()
        query.includeKey("properties")
        
        let exercise = query.getObjectWithId(self.objectId)
        result = exercise.valueForKey("properties") as? [Property]
        
        return result!
    }
    
    func valueForPropertyKey(key: String) -> Double{
        var result = 0.0
        
        for property in self.properties{
            if property.key == key{
                result = property.value
                break
            }
        }
        return result
    }
    
    func saveToHealthKit(){
        let hkm = HealthManager.defaultInstance
        hkm.authorizeHealthKit(nil)
        
        let device = DeviceManager.detailsForDevice(self.device)
        let duration = self.valueForPropertyKey("Time")
        let distance = self.valueForPropertyKey("Distance")
        let level = self.valueForPropertyKey("Level")
        let kiloGrams = 96.0
        
        if device.name == "Walking"{
            hkm.saveRunningWorkout(self.createdAt, duration:duration, distance: distance, level: level, kiloGrams: kiloGrams,
                completion: {(success:Bool, error:NSError!)->Void in
            })
        }
        if device.name == "Cycling"{
            hkm.saveCyclingWorkout(self.createdAt, duration:duration, distance: distance, level: level, kiloGrams: kiloGrams,
                completion: {(success:Bool, error:NSError!)->Void in
            })
        }
    }
    
    
    func addDevice(device:Device){
        self.device = device
        
        //Add properties
        for propertyKey in device.propertyKeys{
            var property = Property()
            
            property.key = propertyKey
            property.value = 0.0
            self.properties.append(property)
        }
    }
}
