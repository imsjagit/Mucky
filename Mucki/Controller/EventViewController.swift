//
//  EventViewController.swift
//  Mucki
//
//  Created by Hans Scheurlen on 11.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class EventViewController: UITableViewController {
    private var events:[Event]?
    private var formatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.formatter.dateFormat  = "yyyy-MM-dd HH:mm"
        self.events = [Event]()
        
        //Register notifications
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "onLoadData", name: kEventDataEventUploadSuccess, object: nil)
        nc.addObserver(self, selector: "onLoadData", name: kEventDataEventDeleteSuccess, object: nil)
        
        //Filll table with data
        self.onLoadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ///////////////////////////////////////////
    // Callback methods
    ///////////////////////////////////////////
    
    func onLoadData(){
        EventManager.allEvents({(events:[Event]) in
            self.events = events
            self.tableView.reloadData()
        })
    }
    
    @IBAction func onRefresh(){
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        //Load data
        NSOperationQueue().addOperationWithBlock({
            ParseManager.importClasses(["Device","Event","Exercise", "Property"], callback:{
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    HUDController.sharedController.hide()
                    
                    self.onLoadData()
                })
            })
        })
    }
    
    ///////////////////////////////////////////
    // UITableViewDataSource methods
    ///////////////////////////////////////////
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.events!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as UITableViewCell
        
        let event = self.events![indexPath.row]
        
        cell.textLabel!.text = event.name        
        cell.detailTextLabel?.text = self.formatter.stringFromDate(event.date)
        
        return cell
    }
    
    ///////////////////////////////////////////
    // UITableViewDelegate methods
    ///////////////////////////////////////////
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let event = self.events![indexPath.row]
            
            EventManager.deleteEvent(event)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        var event:Event? = nil
        
        if segue.identifier == "ShowEvent" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                event = self.eventForIndexPath(indexPath)
            }
        }
        
        let controller = segue.destinationViewController as EventDetailViewController
        controller.currentEvent = event
    }

    private func eventForIndexPath(indexPath: NSIndexPath) -> Event{
        var event:Event?
        
        /*
        let sectionName = self.sections![indexPath.section]
        if let items = self.recipies![sectionName]{
            result = items[indexPath.row] as Recipy
        }
        */
        event = self.events![indexPath.row]

        return event!
    }
    
}

