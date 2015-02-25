//
//  EventManager.swift
//  Mucki
//
//  Created by Hans Scheurlen on 13.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class EventManager: NSObject {
    class func allEvents(callback:(events:[Event])->()){
        var query = PFQuery(className: "Event")
        query.fromLocalDatastore()
        query.addDescendingOrder("date")
        query.includeKey("exercises")
        
        query.findObjectsInBackgroundWithBlock({(data:[AnyObject]!, error:NSError!) in
            var eventData = data as [Event]
            if error != nil{
                var demoEvent = Event()
                demoEvent.name = "Error"
                
                eventData.append(demoEvent)
                
                callback(events: eventData)
            }else{
                if data.count == 0{
                    var demoEvent = Event()
                    demoEvent.name = "Demo"
                    demoEvent.date = NSDate()
                    
                    eventData.append(demoEvent)
                }
                callback(events: eventData)
            }
        })
    }
    
    class func newEvent() -> Event{
        var result = Event()
        
        result.name = ""
        result.comment = ""
        result.date = NSDate()
        result.location = PFGeoPoint()
        result.exercises = [Exercise]()
        
        return result
    }

    class func saveEvent(event:Event){
        event.pinWithName(Event.parseClassName())
        event.saveEventually({(succeeded:Bool, error: NSError!) in
            if succeeded{
                //Save exercises
                for exercise in event.exercises{
                    exercise.pinWithName(Exercise.parseClassName())
                    exercise.saveEventually()
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(kEventDataEventUploadSuccess, object: nil)
            }else{
                println("Save event error: \(error.description)")
            }
        })
    }

    class func deleteEvent(event:Event){
        event.unpinInBackgroundWithName("Event", ({(succeeded:Bool, error: NSError!) in
            if succeeded{
                event.deleteEventually()
                
                NSNotificationCenter.defaultCenter().postNotificationName(kEventDataEventDeleteSuccess, object: nil)
                
            }else{
                println("Delete event error: \(error.description)")
            }
        })
        )
    }
    
    class func saveExercise(exercise:Exercise){
        exercise.saveEventually({(succeeded:Bool, error: NSError!) in
            if succeeded{
                //Save exercises
                for property in exercise.properties{
                    property.pinWithName(Property.parseClassName())
                    property.saveEventually()
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(kEventDataExerciseUploadSuccess, object: nil)
            }else{
                println("Save event error: \(error.description)")
            }
        })
    }
}
