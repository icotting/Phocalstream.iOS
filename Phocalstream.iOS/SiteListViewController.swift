//
//  SiteListViewController.swift
//  Phocalstream.iOS
//
//  Created by Ian Cottingham on 9/29/14.
//  Copyright (c) 2014 Jeffrey S. Raikes School. All rights reserved.
//

import UIKit

class SiteListViewController: UIViewController, RequestManagerDelegate {

    var sites: Array<AnyObject>?
    @IBOutlet weak var siteListDataSource: SiteListTableViewDelegate!
    @IBOutlet weak var siteListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        var mgr = RequestManager()
        mgr.delegate = self
        
        mgr.makeJsonCallWithEndpoint("http://images.plattebasintimelapse.org/api/sitecollection/list")
    }

    func didFailWithResponseCode(code: Int) {
        var alert = UIAlertView(title: "Error", message: "Could not load the site data", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func didSucceedWithBody(body: Array<AnyObject>) {
        self.sites = body
        self.siteListDataSource.sites = self.sites
        
        dispatch_async(dispatch_get_main_queue(), {
            self.siteListTableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
