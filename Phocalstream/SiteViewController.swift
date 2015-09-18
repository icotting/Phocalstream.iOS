//
//  SiteViewController.swift
//  Phocalstream
//
//  Created by Ian Cottingham on 5/19/15.
//  Copyright (c) 2015 JS Raikes School. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SiteViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, RequestManagerDelegate {

    weak var pageController: UIPageViewController!
    
    var sites = [CameraSite]()
    
    @IBAction func logoff() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mgr = RequestManager(delegate: self)
        mgr.makeJsonCallWithEndpoint("http://images.plattebasintimelapse.org/api/usercollection/usersites")
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        let siteContentController = self.storyboard?.instantiateViewControllerWithIdentifier("SiteContentController") as! SiteContentViewController
        
        siteContentController.coverPhotoID = sites[index].coverPhotoID!
        siteContentController.siteName = sites[index].name!
        
        if sites[index].photoCount == 1 {
        siteContentController.siteDetails = String(format: "Showing %d photo from %@", sites[index].photoCount!, (sites[index].from?.toString("MM/dd/YYYY")!)!)
        }
        else {
            siteContentController.siteDetails = String(format: "Showing %d photos from %@ to %@", sites[index].photoCount!, (sites[index].from?.toString("MM/dd/YYYY")!)!, (sites[index].to?.toString("MM/dd/YYYY"))!)
        }
        siteContentController.pageIndex = index
        return siteContentController
    }
    
    // MARK: PageViewController Datasource Methods
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = NSNotFound
        
        index = (viewController as! SiteContentViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == (sites.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = NSNotFound
        
        index = (viewController as! SiteContentViewController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index--
        return viewControllerAtIndex(index)
    }

    
    // MARK: RequestManager Delegate Methods
    
    func didFailWithResponseCode(code: Int) {
        print(code)
    }
    
    func didSucceedWithBody(body: Array<AnyObject>?) {
        self.pageController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as? UIPageViewController
        self.pageController.dataSource = self;
        
        print(body!)
        
        for item in body! {
            self.sites.append(CameraSite(json: item))
        }
        
        let siteContentController = self.viewControllerAtIndex(0)!
        self.pageController.setViewControllers([siteContentController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        self.addChildViewController(self.pageController)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.view.addSubview(self.pageController!.view)
            self.pageController.didMoveToParentViewController(self)
            self.view.sendSubviewToBack(self.pageController.view)
        })
    }
}
