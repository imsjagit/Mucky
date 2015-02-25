//
//  Event.swift
//  Mucki
//
//  Created by Hans Scheurlen on 13.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit
import CoreLocation

class Event: PFObject,PFSubclassing  {

    //////////////////////////////////
    // MARK: - Subclasing methods
    //////////////////////////////////
    
    override class func load() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "Event"
    }
    
    //////////////////////////////////
    // MARK: - Properties
    //////////////////////////////////
    var name:String {
        get { return self["name"] as String }
        set { self["name"] = newValue }
    }
    var comment:String {
        get { return self["comment"] as String }
        set { self["comment"] = newValue }
    }
    var date:NSDate {
        get { return self["date"] as NSDate }
        set { self["date"] = newValue }
    }
    var location:PFGeoPoint {
        get { return self["location"] as PFGeoPoint }
        set { self["location"] = newValue }
    }
    var exercises:[Exercise] {
        get {
            var result:[Exercise]?
            
            if self.objectForKey("exercises") != nil{
                result = self["exercises"] as? [Exercise]
            }else{
                result = [Exercise]()
            }
            return result!
        }
        set { self["exercises"] = newValue }
    }
    
    var isSaved:Bool {
        get{
            return self.objectId != nil
        }
    }
    
    func addExerciseForDevice(device:Device){
        var exercise = Exercise()
        
        exercise.addDevice(device)
        
        //Store in array
        self.exercises.append(exercise)

        EventManager.saveEvent(self)

        exercise.saveEventually({(succeeded:Bool, error: NSError!) in
            if succeeded{
                //Save exercises
                for property in exercise.properties{
                    property.pinWithName(Property.parseClassName())
                    property.saveEventually()
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(kEventDataExerciseUploadSuccess, object: nil)
            }else{
                println("Save exercise error: \(error.description)")
            }
        })
    }

    func deleteExerciseWithIndex(index:Int){
        
        //Delete from array
        let exercise = self.exercises[index]
        
        self.exercises.removeAtIndex(index)
        
        exercise.unpinInBackgroundWithName("Exercise", ({(succeeded:Bool, error: NSError!) in
            if succeeded{
                exercise.deleteEventually()
                
                //Delete properties
                for property in exercise.properties{
                    property.unpinWithName("Property")
                    property.deleteEventually()
                }
                EventManager.saveEvent(self)
                NSNotificationCenter.defaultCenter().postNotificationName(kEventDataExerciseDeleteSuccess, object: nil)
                
            }else{
                println("Delete exercise error: \(error.description)")
            }
        })
        )
    }

}
