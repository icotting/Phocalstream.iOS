//
//  CameraSitesViewContoller.swift
//  Phocalstream
//
//  Created by Zach Christensen on 11/11/15.
//  Copyright © 2015 JS Raikes School. All rights reserved.
//

import Foundation
import UIKit

class CameraSitesViewContoller : UITableViewController, RequestManagerDelegate {

    var mgr: RequestManager!
    var dialog: LoadingDialog!
    var sites = [PhocalstreamSite]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "CameraSiteCell", bundle: nil), forCellReuseIdentifier: "CameraSiteCell")
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView?.hidden = true

        self.dialog = LoadingDialog(title: "Loading Sites...")
        self.dialog.presentFromView(self.view)

        self.mgr = RequestManager(delegate: self)
        mgr.makeJsonCallWithEndpoint("http://images.plattebasintimelapse.com/api/sitecollection/list")

        
        //sites = [CameraSite(collectionID: 1, coverPhotoID: 100, name: "Test Site", photoCount: 100, from: NSDate(), to: NSDate()),
                 //CameraSite(collectionID: 2, coverPhotoID: 78420, name: "New Test Site", photoCount: 2000, from: NSDate(), to: NSDate())]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CameraSiteDetailsSegue" {
            (segue.destinationViewController as! CameraSiteDetailsViewController).setSite(self.sites[sender as! Int])
        }
    }
    
    // MARK: UITableViewDelegate and UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sites.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 268
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cameraSiteCell: CameraSiteCell = self.tableView.dequeueReusableCellWithIdentifier("CameraSiteCell") as! CameraSiteCell
        cameraSiteCell.loadItem(sites[indexPath.row])
        cameraSiteCell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cameraSiteCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("CameraSiteDetailsSegue", sender: indexPath.row)
    }
    
    
    // MARK: RequestManagerDelegate
    func didFailWithResponseCode(code: Int, message: String?) {
        
    }
    
    func didSucceedWithBody(body: Array<AnyObject>?) {
        for item in body! {
            self.sites.append(PhocalstreamSite(json: item))
        }
    
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.dialog?.clearFromView()
        })
    }
    
    func didSucceedWithObjectId(id: Int64) {
        
    }

}