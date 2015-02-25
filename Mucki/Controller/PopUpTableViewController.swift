//
//  PopUpTableViewControllerSwift.swift
//  NMPopUpView
//
//  Created by Nikos Maounis on 13/9/14.
//  Modified by imsja
//  Copyright (c) 2014 Nikos Maounis. All rights reserved.
//

import UIKit
import QuartzCore

let kEventPopUpTableViewController = "EventPopUpTableViewController"
let kPopupTableViewControllerSelection = "kopupTableViewControllerSelection"

@objc class PopUpTableViewController : UITableViewController {
    
    let items: [PFObject]
    let key:String
    let headerTitle:String
    let notificationName:String
    var parentView:UIView?
    
    required init(coder aDecoder: NSCoder) {
        self.items = [PFObject]()
        self.key = ""
        self.headerTitle = ""
        self.notificationName = ""
        
        super.init(coder: aDecoder)
    }
    
    init(items: [PFObject], key: String, title:String, notificationName: String, nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        self.items = items
        self.key = key
        self.headerTitle = title
        self.notificationName = notificationName
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(items: [PFObject], key: String,  title:String, notificationName:String){
        self.init(items: items, key: key,  title:title, notificationName: notificationName, nibName: nil, bundle:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        
        //Register cell
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SelectionCell")
        
    }
    
    func showInView(aView: UIView!, animated: Bool)
    {
        self.parentView = aView
        
        //Calculate size
        let height = min(44.0 * CGFloat(self.items.count + 1), aView.frame.size.height)
        let width = aView.frame.size.width * 0.66666
        
        let frame = aView.frame// UIScreen.mainScreen().bounds
    
        
        let app = UIApplication.sharedApplication()
        var y = (frame.size.height - height ) / 2.0
        if !app.statusBarHidden {
            y = y + 22.0
        }
        
        if let responder = aView.nextResponder(){
            //Parent view must have a controller assigned
            if responder.isKindOfClass(UIViewController){
                let controller = responder as UIViewController
                if let navController = controller.navigationController{
                    //y = y + 44.0
                }
                
            }
        }
        
        let x = frame.width * 0.16666
        self.view.frame.origin.x = x
        self.view.frame.origin.y = y
        self.view.frame.size.height = height
        self.view.frame.size.width = width
        
        self.view.setBorderRadius( 20.0 )
        
        aView.addSubview(self.view)
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            if let pv = self.parentView{
                //pv.alpha = 0.5
            }
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    if let pv = self.parentView{
                        pv.alpha = 1.0
                    }
                    
                    self.view.removeFromSuperview()
                }
        });
    }
    //////////////////////////////////
    // MARK: - Call backs
    //////////////////////////////////
    func onClose() {
        self.removeAnimate()
    }
    
    //////////////////////////////////
    // MARK: - Table view data source
    //////////////////////////////////
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let image = UIImage(named: "close-button.png")
        let xOffset = self.tableView.frame.width - image!.size.width

        var frame = CGRect(origin: CGPoint(x:0.0, y:0.0), size: CGSize(width:tableView.frame.size.width, height: 44.0))
        var headerView = UIView()
        headerView.frame = frame
        headerView.backgroundColor = UIColor.blackColor()
        
        frame = CGRect(origin: CGPoint(x:xOffset, y:0.0), size: CGSize(width:image!.size.width, height: 44.0))
        var closeButton = UIButton(frame: frame)
        closeButton.addTarget(self, action: "onClose", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.tintColor = UIColor.redColor()
        closeButton.setImage(image, forState: UIControlState.Normal)
        
        headerView.addSubview(closeButton)
        
        frame = CGRect(origin: CGPoint(x:0.0, y:0.0), size: CGSize(width: tableView.frame.size.width,height: 44.0))
        var label = UILabel(frame: frame)
        label.text = self.headerTitle
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectionCell", forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.contentView.backgroundColor = UIColor.grayColor()
        
        let item = self.items[indexPath.row]
        
        var label = cell.textLabel!
        let key = item[self.key] as String
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.text = key
        
        if let iv = cell.imageView{
            let imageName = key + ".png"
            iv.image = UIImage(named: imageName)
        }
        return cell
    }
    
    //////////////////////////////////
    // MARK: - Table view delegate
    //////////////////////////////////
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification =  NSNotification(name: kEventPopUpTableViewController, object: items[indexPath.row])
        
        NSNotificationCenter.defaultCenter().postNotificationName(self.notificationName,
            object: nil,
            userInfo: [kPopupTableViewControllerSelection:items[indexPath.row]])
        
        self.removeAnimate()
    }
}
