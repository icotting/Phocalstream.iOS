//
//  CreateSiteController.swift
//  Phocalstream
//
//  Created by Zach Christensen on 9/18/15.
//  Copyright © 2015 JS Raikes School. All rights reserved.
//

import UIKit
import Foundation

import CoreLocation

class CreateSiteController : UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, RequestManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    @IBOutlet weak var siteNameField: UITextField!
    @IBOutlet weak var siteLocationField: UITextField!
    @IBOutlet weak var siteImageThumbnail: UIImageView!
    
    var siteId: Int!
    var siteName: String!
    var siteLat: Double!
    var siteLong: Double!
    var county: String!
    var state: String!
    
    var siteImage: UIImage!
    
    var dialog: LoadingDialog!
    var geocoder: CLGeocoder!
    var manager: CLLocationManager!
    var mgr: RequestManager!
    
    override func viewDidLoad() {

        siteNameField.delegate = self
        
        // Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()

        // Init Geocoder
        geocoder = CLGeocoder()
        
        mgr = RequestManager(delegate: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        manager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(animated: Bool) {
        manager.stopUpdatingLocation()
    }
    
    func isSiteValid() -> Bool {
        return (siteName != nil && siteLat != nil && siteLong != nil && county != nil && state != nil && siteImage != nil)
        
    }
    
    // MARK: Toolbar Actions
    
    @IBAction func close(sender: AnyObject) {
    }
    
    @IBAction func create(sender: AnyObject) {
        self.dialog = LoadingDialog(title: "Creating Site")
        self.dialog.presentFromView(self.view)
        
        //string siteName, double latitude, double longitude, string county, string state
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.siteName, forKeyPath: "SiteName")
        dictionary.setValue(String(self.siteLat), forKeyPath: "Latitude")
        dictionary.setValue(String(self.siteLong), forKeyPath: "Longitude")
        dictionary.setValue("\(self.county) County", forKeyPath: "County")
        dictionary.setValue(self.state, forKeyPath: "State")
        
        self.mgr.postWithData("http://images.plattebasintimelapse.org/api/usercollection/CreateUserCameraSite", data: dictionary)
    }
    
    // MARK: Photo Capture

    @IBAction func addPhoto(sender: AnyObject) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            self.capturePhoto()
        } else {
            self.noCamera()
        }
    }
    
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

        self.siteImage = info[UIImagePickerControllerOriginalImage] as! UIImage

        self.siteImageThumbnail.image = self.siteImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        
        self.siteImage = nil
        self.siteImageThumbnail.image = nil
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

    
    // MARK: RequestManager Delegate Methods
    
    func didFailWithResponseCode(code: Int, message: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            print("\(code): \(message!)")
            self.dialog.clearFromView()
        })
    }
    
    func didSucceedWithBody(body: Array<AnyObject>?) {
        // If the body is not nil, it is the first call to create the site
        if body != nil {
            let id = (body!.first as! String!)
            self.siteId = Int(id)
            
            self.dialog.updateTitle("Uploading Photo")
            
            self.mgr.uploadPhoto("http://images.plattebasintimelapse.org/api/upload/upload?selectedCollectionID=\(self.siteId)", image: self.siteImage!)
        }
    }
    
    func didSucceedWithObjectId(id: Int64) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dialog.clearFromView()
        })
        performSegueWithIdentifier("UNWINDANDRELOAD", sender: self)
    }
    
    
    // MARK: CLLocationManagerDelete Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.siteLat = locations[0].coordinate.latitude
        self.siteLong = locations[0].coordinate.longitude
        siteLocationField.text = "( \(locations[0].coordinate.latitude), \(locations[0].coordinate.longitude) )"
        
        self.geocoder.reverseGeocodeLocation(locations[0], completionHandler: {(placemarks, error) in
            if let placemark: CLPlacemark = placemarks?[0] {
                self.county = placemark.subAdministrativeArea!
                self.state = placemark.administrativeArea!
                self.createButton.enabled = self.isSiteValid()
            }
        })
        
    }

    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.siteName = siteNameField.text
        createButton.enabled = isSiteValid()
    }

    
    
}