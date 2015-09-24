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

class SiteViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RequestManagerDelegate {

    @IBOutlet weak var takePhotoButton: UIBarButtonItem!
    @IBOutlet weak var addSiteButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    weak var pageController: UIPageViewController!
    
    var dialog: LoadingDialog!
    var mgr: RequestManager!
    var sites = [CameraSite]()
    var currentId: Int64!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mgr = RequestManager(delegate: self)
        mgr.makeJsonCallWithEndpoint("http://images.plattebasintimelapse.org/api/usercollection/usersites")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.takePhotoButton.tintColor = UIColor.blackColor()
        self.addSiteButton.tintColor = UIColor.blackColor()
        self.logoutButton.tintColor = UIColor.blackColor()
    }
    
    @IBAction func unwindFromAddSite(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindAndReloadSites(segue: UIStoryboardSegue) {
        self.sites = [CameraSite]()
        self.currentId = nil
        self.mgr.makeJsonCallWithEndpoint("http://images.plattebasintimelapse.org/api/usercollection/usersites")
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        let siteContentController = self.storyboard?.instantiateViewControllerWithIdentifier("SiteContentController") as! SiteContentViewController
        
        siteContentController.collectionID = sites[index].collectionID
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
    
    // MARK: Toolbar Actions
    
    @IBAction func takePhoto(sender: AnyObject) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            self.capturePhoto()
        } else {
            self.noCamera()
        }
    }
    
    @IBAction func logoff(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Photo Capture
    
    func choosePhotofromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func capturePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func noCamera(){
        let alert = UIAlertView(title: "No Camera", message: "Sorry, this device does not have a camera. Choose an image from photo library?", delegate: self, cancelButtonTitle: "No")
        alert.addButtonWithTitle("Yes")
        
        alert.show()
    }
    
    
    // MARK: UIImagePickerController Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        self.dialog = LoadingDialog(title: "Uploading Photo")
        self.dialog.presentFromView(self.view)
        
        mgr.uploadPhoto("http://images.plattebasintimelapse.org/api/upload/upload?selectedCollectionID=\(self.currentId)", image: info[UIImagePickerControllerOriginalImage] as! UIImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: UIAlertView Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "Upload a photo?" {
            if buttonIndex == 1 {
                self.capturePhoto()
            }
        }
        else if alertView.title == "No Camera" {
            if buttonIndex == 1 {
                self.choosePhotofromLibrary()
            }
        }
    }
    
    
    // MARK: PageViewController Datasource Methods
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = NSNotFound
        
        index = (viewController as! SiteContentViewController).pageIndex
        self.currentId = self.sites[index].collectionID
        print("After: \(self.currentId)")
        
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
        self.currentId = self.sites[index].collectionID
        print("Before: \(self.currentId)")

        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index--
        return viewControllerAtIndex(index)
    }
    
    // MARK: RequestManager Delegate Methods
    
    func didFailWithResponseCode(code: Int, message: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dialog.clearFromView()
        })
    }
    
    func didSucceedWithBody(body: Array<AnyObject>?) {
        if body != nil {
            self.pageController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as? UIPageViewController
            self.pageController.dataSource = self;
            
            for item in body! {
                self.sites.append(CameraSite(json: item))
            }
            
            self.currentId = self.sites[0].collectionID
            
            let siteContentController = self.viewControllerAtIndex(0)!
            self.pageController.setViewControllers([siteContentController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            self.addChildViewController(self.pageController)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.view.addSubview(self.pageController!.view)
                self.pageController.didMoveToParentViewController(self)
                self.view.sendSubviewToBack(self.pageController.view)
            })
        }
        // returning from photop upload, so dismiss dialog
        else {
            dispatch_async(dispatch_get_main_queue(), {
                self.dialog.clearFromView()
            })
        }
    }
}
