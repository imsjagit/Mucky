//
//  EventDetailViewController.swift
//  Mucki
//
//  Created by Hans Scheurlen on 16.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class EventDetailViewController: FormViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var txtName:UITextField?
    @IBOutlet weak var tvComment:UITextView?
    @IBOutlet weak var tblExercises:UITableView?
    
    var currentEvent:Event?
    private var popViewController:PopUpTableViewController?
    private var formatter = NSDateFormatter()
    
    deinit {
        //Deregister notifications
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    ///////////////////////////////////////////
    // View methods
    ///////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.formatter.dateFormat  = "yyyy-MM-dd HH:mm"
        
        //Add bar buttons
        let btnSave = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "onSave")
        self.navigationItem.rightBarButtonItem = btnSave
        
        // Do any additional setup after loading the view.
        if self.currentEvent == nil{
            self.currentEvent = EventManager.newEvent()
        }
        self.txtName!.text = self.currentEvent!.name
        self.tvComment!.text = self.currentEvent!.comment
        
        //Preload masterdata
        DeviceManager.allDevices()
        
        //Register notifications
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "onDeviceSelectedNotification:", name: kEventDeviceSelectedNotification, object: nil)
        nc.addObserver(self, selector: "onLoadData", name: kEventDataEventUploadSuccess, object: nil)
        nc.addObserver(self, selector: "onLoadData", name: kEventDataExerciseDeleteSuccess, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///////////////////////////////////////////
    // Callback methods
    ///////////////////////////////////////////
    func onLoadData(){
        self.tblExercises!.reloadData()
    }
    
    @IBAction func onSave() {
        self.currentEvent!.name = self.txtName!.text
        self.currentEvent!.comment = self.tvComment!.text
        
        EventManager.saveEvent(self.currentEvent!)
        
        if let navController = self.navigationController{
            navController.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func onAddExercise() {
        /*
        DeviceManager.allDevices({(devices:[Device]) in
            self.popViewController = PopUpTableViewController(items: devices,
                key: "name",
                notificationName: kEventDeviceSelected)
            
            //Disable tap handling from parent class
            self.shouldHandleTouches = false
            
            self.popViewController!.title = "Devices"
            self.popViewController!.showInView(self.view, animated: true)
        })
        */
        self.popViewController = PopUpTableViewController(items: DeviceManager.allDevices(),
            key: "name",
            title: "Devices",
            notificationName: kEventDeviceSelectedNotification)
        
        //Disable tap handling from parent class
        self.shouldHandleTouches = false
        
        self.popViewController!.title = "Devices"
        self.popViewController!.showInView(self.view, animated: true)
        
    }
    
    func onDeviceSelectedNotification(notification : NSNotification){
        if let userInfo  = notification.userInfo{
            let dict = userInfo as [String:Device]
            if let device = dict[kPopupTableViewControllerSelection]{
                self.currentEvent!.addExerciseForDevice(device)
                
                //Enable tap handling from parent class
                self.shouldHandleTouches = true
            }
        }
    }
    
    ///////////////////////////////////////////
    // UITableViewDataSource methods
    ///////////////////////////////////////////
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.currentEvent!.exercises.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell") as UITableViewCell
        
        let exercise = self.currentEvent!.exercises[indexPath.row]
        let device = exercise.device
        cell.textLabel!.text = device.name
        cell.detailTextLabel!.text = formatter.stringFromDate(exercise.updatedAt)
        return cell
        
    }
    
    ///////////////////////////////////////////
    // UITableViewDelegate methods
    ///////////////////////////////////////////
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.currentEvent!.deleteExerciseWithIndex(indexPath.row)
        }
    }
    
    
    ///////////////////////////////////////////
    // Navigation methods
    ///////////////////////////////////////////
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var exercise:Exercise?
        
        if segue.identifier == "Properties" {
            if let indexPath = self.tblExercises!.indexPathForSelectedRow() {
                exercise = self.currentEvent!.exercises[indexPath.row] as Exercise
            }
        }
        
        let controller = segue.destinationViewController as ExerciseViewController
        controller.currentExercise = exercise!
    }

}
