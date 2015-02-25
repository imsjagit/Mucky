//
//  DeviceManager.swift
//  Mucki
//
//  Created by Hans Scheurlen on 13.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class DeviceManager: NSObject {
    private var devices:[Device]?
    
    class var defaultInstance:DeviceManager {
        get {
            struct Static {
                static var instance : DeviceManager? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) {
                Static.instance = DeviceManager()
            }
            
            return Static.instance!
        }
    }

    class func allDevices() ->[Device]{
        var result: [Device]?
        var query = PFQuery(className: "Device")
        query.fromLocalDatastore()
        query.addAscendingOrder("name")
        
        result = query.findObjects() as? [Device]
        
        self.defaultInstance.devices = result
        
        return result!
    }

    class func allDevices(callback:(devices:[Device])->()){
        var query = PFQuery(className: "Device")
        query.fromLocalDatastore()
        query.addAscendingOrder("name")
        
        query.findObjectsInBackgroundWithBlock({(data:[AnyObject]!, error:NSError!) in
            var deviceData = data as [Device]
            if error != nil{
                var demoType = Device()
                demoType.name = "Error"
                
                deviceData.append(demoType)
                
                callback(devices: deviceData)
            }else{
                if data.count == 0{
                    var demoType = Device()
                    demoType.name = "Demo"
                    
                    deviceData.append(demoType)
                }
                callback(devices: deviceData)
            }
            
            if error != nil{
                callback(devices: [Device]())
            }else{
                callback(devices: data as [Device])
            }
        })
    }
    
    class func detailsForDevice(device: Device) -> Device{
        var query = PFQuery(className: "Device")
        query.fromLocalDatastore()

        return query.getObjectWithId(device.objectId) as Device
    }
}
