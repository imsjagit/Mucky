//
//  ExerciseViewController.swift
//  Mucki
//
//  Created by Hans Scheurlen on 18.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class ExerciseViewController: FormViewController, UITableViewDataSource {
    var currentExercise:Exercise?
    private var properties:[Property]?
    private var txtDictionary:[String:UITextField]?
    
    @IBOutlet weak var tblProperties:UITableView?
    
    ///////////////////////////////////////////
    // View methods
    ///////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add bar buttons
        let btnSave = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "onSave")
        self.navigationItem.rightBarButtonItem = btnSave
        
        // Do any additional setup after loading the view.
        self.properties = self.currentExercise!.loadProperties()// properties
        
        self.txtDictionary = [String:UITextField]()
        
        //Register notifications
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "onDeviceSelected:", name: kEventExerciseSelectedNotification, object: nil)
        
        //Load tableview
        self.tblProperties!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///////////////////////////////////////////
    // Callback methods
    ///////////////////////////////////////////
    @IBAction func onSave() {
        //Copy values from tableView into objects
        for property in self.properties!{
            if let txtField = self.txtDictionary![property.key]{
                property.value = txtField.text.doubleValue()
            }
        }
        
        EventManager.saveExercise(self.currentExercise!)
        
        //Save to HealthKit
        self.currentExercise!.saveToHealthKit()
        
        if let navController = self.navigationController{
            navController.popViewControllerAnimated(true)
        }
    }
    ///////////////////////////////////////////
    // UITableViewDataSource methods
    ///////////////////////////////////////////
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.currentExercise!.properties.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("PropertyCell") as UITableViewCell
        
        let property = self.currentExercise!.properties[indexPath.row]
        let key = property.key
        
        /*
        */
        let frame = cell.contentView.frame
        let labelWidth = 120.0
        let labelFrame = CGRectMake(20.0, 2.0, CGFloat(labelWidth), 40.0)
        let textFrame = CGRectMake(20.0 + 10.0 + labelFrame.size.width, 2.0, frame.size.width - CGFloat(labelWidth), 40.0)
        
        var label = UILabel(frame:labelFrame)
        label.text = "\(key.capitalizedString):"
        label.textAlignment = NSTextAlignment.Right
        
        var txtField = UITextField(frame: textFrame)
        txtField.placeholder = property.key
        txtField.autocorrectionType = UITextAutocorrectionType.No
        txtField.clearButtonMode = UITextFieldViewMode.Never
        txtField.text = NSString(format: "%.2f", property.value)

        cell.contentView.addSubview(label)
        cell.contentView.addSubview(txtField)

        self.txtDictionary![key] = txtField
        /*
        let label = cell.contentView.viewWithTag(0) as UILabel
        label.text = property.key
        let text = cell.contentView.viewWithTag(1) as UITextField
        text.text = NSString(format: "%.2d", property.value)
        */
        
        return cell
        
    }
    
}
