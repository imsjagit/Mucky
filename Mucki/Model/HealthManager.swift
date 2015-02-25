//
//  HealthManager.swift
//  Mucki
//
//  Created by Hans Scheurlen on 22.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
    let healthKitStore:HKHealthStore
    
    override init(){
        self.healthKitStore = HKHealthStore()
        
        super.init()
    }

    
    //Creates singleton
    class var defaultInstance:HealthManager {
        get {
            struct Static {
                static var instance : HealthManager? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) {
                Static.instance = HealthManager()
            }
            
            return Static.instance!
        }
    }
    
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            HKObjectType.workoutType()
            ])
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling),
            HKQuantityType.workoutType()
            ])
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.imsja.mucki", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }

    func saveRunningWorkout(startDate: NSDate, duration: Double , distance:Double, level: Double, kiloGrams:Double,
        completion: ( (Bool, NSError!) -> Void)!) {
            //Estimated formula
            let kiloCalories = 0.041 * kiloGrams * Double(duration)
            self.saveWorkout(startDate, duration: duration, distance: distance, kiloGrams:kiloGrams, kiloCalories: kiloCalories, workoutType: HKWorkoutActivityType.Walking, distanceType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning), completion: completion)
            
    }
    
    func saveCyclingWorkout(startDate: NSDate, duration: Double , distance:Double, level: Double, kiloGrams:Double,
        completion: ( (Bool, NSError!) -> Void)!) {
            //Estimated formula see http://www.cptips.com/formul2.htm
            let time = duration * 60
            let v = distance / time
            let pw = v * (3.509 + (0.2581 * v * v))
            let pc = pw / 4186.8
            let ceh = pc / time
            let cih = ceh / 0.25
            
            let w = kiloGrams * level
            let cev = w / 418
            let civ = cev / 0.25
            
            let kiloCalories = (civ + cih) + 0.666 * 50.0
            
            self.saveWorkout(startDate, duration: duration, distance: distance, kiloGrams:kiloGrams, kiloCalories: kiloCalories, workoutType: HKWorkoutActivityType.Cycling, distanceType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling), completion: completion)
            
    }
    
    private func saveWorkout(startDate: NSDate, duration: Double , distance:Double, kiloGrams:Double, kiloCalories: Double, workoutType: HKWorkoutActivityType, distanceType: HKQuantityType,
        completion: ( (Bool, NSError!) -> Void)!) {
            
            // 1. Create quantities for the distance and energy burned
            let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
            
            let caloriesQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: kiloCalories)
            
            // 2. Save Running Workout
            let endDateInMilliSeconds = startDate.timeIntervalSince1970 + (NSTimeInterval(duration) * 60 * 1000)
            let endDate = NSDate(timeIntervalSince1970: endDateInMilliSeconds)
            
            let workout = HKWorkout(activityType: workoutType, startDate: startDate, endDate: endDate, duration: abs(endDate.timeIntervalSinceDate(startDate)), totalEnergyBurned: caloriesQuantity, totalDistance: distanceQuantity, metadata: nil)
            
            healthKitStore.saveObject(workout, withCompletion: { (success, error) -> Void in
                if( error != nil  ) {
                    // Error saving the workout
                    completion(success,error)
                }
                else {
                    // if success, then save the associated samples so that they appear in the HealthKit
                    let distanceSample = HKQuantitySample(type: distanceType, quantity: distanceQuantity, startDate: startDate, endDate: endDate)
                    let caloriesSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned), quantity: caloriesQuantity, startDate: startDate, endDate: endDate)
                    
                    self.healthKitStore.addSamples([distanceSample,caloriesSample], toWorkout: workout, completion: { (success, error ) -> Void in
                        completion(success, error)
                    })
                    
                }
            })            
    }
}
