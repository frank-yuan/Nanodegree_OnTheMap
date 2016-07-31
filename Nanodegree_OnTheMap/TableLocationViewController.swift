//
//  UDTableViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/26/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class TableLocationViewController: LocationViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableViewCellIdentifier = "locationCell"
    
    @IBOutlet weak var tableView:UITableView!

    // MARK: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserLocationData.getInstance().locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath)
        
        let location = UserLocationData.getInstance().locations[indexPath.row]
        cell.textLabel?.text = location.lastName + " " + location.firstName
        cell.detailTextLabel?.text = location.mediaURL
        // Show disclosuer for cell with a valid url
        if let url = NSURL(string: location.mediaURL) where UIApplication.sharedApplication().canOpenURL(url) {
            cell.accessoryType =  .DisclosureIndicator
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let location = UserLocationData.getInstance().locations[indexPath.row]
        let application = UIApplication.sharedApplication()
        
        if let url = NSURL(string: location.mediaURL) where application.canOpenURL(url) {
            application.openURL(url)

        } else {
            let alert = UIAlertController(title: "Invalid URL", message: "The URL provided is invalid", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.selected = false
        }
    }
    
    override func onDataReloaded() {
        self.tableView.reloadData()
    }
    
    override func setUIEnabled(enabled: Bool) {
        super.setUIEnabled(enabled)
        
        tableView.userInteractionEnabled = enabled
    }
}
