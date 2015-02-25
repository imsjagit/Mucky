//
//  SecondViewController.swift
//  Mucki
//
//  Created by Hans Scheurlen on 11.02.15. 
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class DeviceViewController: UITableViewController {
    private var devices:[Device]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.devices = [Device]()

        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    ///////////////////////////////////////////
    // Private methods
    ///////////////////////////////////////////
    
    private func loadData(){
        DeviceManager.allDevices({(devices:[Device]) in
            self.devices = devices
            self.tableView.reloadData()
        })
    }
    

    ///////////////////////////////////////////
    // UITableViewDataSource methods
    ///////////////////////////////////////////
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.devices!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("DeviceTypeCell") as UITableViewCell
        
        let device = self.devices![indexPath.row]
        
        cell.textLabel!.text = device.name
        return cell
    }

}

