//
//  UDTableViewController.swift
//  Nanodegree_OnTheMap
//
//  Created by Xuan Yuan (Frank) on 7/26/16.
//  Copyright © 2016 frank-yuan. All rights reserved.
//

import UIKit

class TableUsersViewController: UsersViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView:UITableView!

    // MARK: Constants
    let tableViewCellIdentifier = "locationCell"
    
    // MARK: Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserLocationData.getInstance().locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath)
        
        let location = UserLocationData.getInstance().locations[indexPath.row]
        cell.textLabel?.text = location.firstName + " " + location.lastName
        cell.detailTextLabel?.text = location.mediaURL
        // Show disclosuer for cell with a valid url
        if let url = NSURL(string: location.mediaURL) where url.scheme.characters.count > 0 && UIApplication.sharedApplication().canOpenURL(url) {
            cell.accessoryType =  .DisclosureIndicator
        } else {
            cell.accessoryType =  .None
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate implements
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
    
    // MARK: Superclass overrides
    override func onDataReloaded() {
        self.tableView.reloadData()
    }
    
    override func setUIEnabled(enabled: Bool) {
        super.setUIEnabled(enabled)
        
        tableView.userInteractionEnabled = enabled
    }
}
