//
//  UIImageExtension.swift
//  Phocalstream
//
//  Created by Zach Christensen on 9/21/15.
//  Copyright © 2015 JS Raikes School. All rights reserved.
//

import UIKit
import Foundation

extension UIImage {
    
    //MARK: UIImage+Resize.m
    // Created by Trevor Harmon on 8/5/09.
    // Free for personal or commercial use, with or without modification.
    // No warranty is expressed or implied.
    
    // Returns a copy of this image that is cropped to the given bounds.
    // The bounds will be adjusted using CGRectIntegral.
    // This method ignores the image's imageOrientation setting.
    func croppedImage(bounds: CGRect) -> UIImage {
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(self.CGImage, bounds)!
        let croppedImage: UIImage = UIImage(CGImage: imageRef)
        return croppedImage
    }
    
    // Returns a rescaled copy of the image, taking into account its orientation
    // The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
    func resizedImage(newSize: CGSize, quality: CGInterpolationQuality) -> UIImage {
        var drawTransposed: Bool
        
        switch (self.imageOrientation) {
        case UIImageOrientation.Left,
        UIImageOrientation.LeftMirrored,
        UIImageOrientation.Right,
        UIImageOrientation.RightMirrored:
            drawTransposed = true
            break
        default:
            drawTransposed = false
        }
        
        return self.resizeImage(newSize, transform: self.transformForOrientation(newSize), transpose: drawTransposed, quality: quality)
    }
    
    // Resizes the image according to the given content mode, taking into account the image's orientation
    func resizedImageWithContentMode(contentMode: UIViewContentMode, bounds: CGSize, quality: CGInterpolationQuality) -> UIImage {
        let horizontalRatio: CGFloat = bounds.width / self.size.width
        let verticalRatio: CGFloat = bounds.height / self.size.height
        var ratio: CGFloat?
        
        switch (contentMode) {
        case UIViewContentMode.ScaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
            break
        case UIViewContentMode.ScaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
            break
        default:
            print("Error: resizedImageWithContentMode()")
        }
        
        let newSize = CGSizeMake(self.size.width * ratio!, self.size.height * ratio!)
        
        return self.resizedImage(newSize, quality: quality)
    }
    
    // Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
    // The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
    // If the new size is not integral, it will be rounded up
    func resizeImage(newSize: CGSize, transform: CGAffineTransform, transpose: Bool, quality: CGInterpolationQuality) -> UIImage {
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        let transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width)
        let imageRef: CGImageRef = self.CGImage!
        
        // Build a context that's the same dimensions as the new size
        let bitmap: CGContextRef = CGBitmapContextCreate(nil, Int(newRect.size.width), Int(newRect.size.height), CGImageGetBitsPerComponent(imageRef), 0,
            CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef).rawValue)!
        
        // Rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform)
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality)
        
        // Draw into the context this scales the image
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef)
        
        // Get the resized image from the context and a UIImage
        let newImageRef: CGImageRef = CGBitmapContextCreateImage(bitmap)!
        let newImage: UIImage = UIImage(CGImage: newImageRef)
        
        return newImage
    }
    
    // Returns an affine transform that takes into account the image orientation when drawing a scaled image
    func transformForOrientation(newSize: CGSize) -> CGAffineTransform {
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch (self.imageOrientation) {
        case UIImageOrientation.Down,          // EXIF = 3
        UIImageOrientation.DownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
            
        case UIImageOrientation.Left,          // EXIF = 6
        UIImageOrientation.LeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
            
        case UIImageOrientation.Right,         // EXIF = 8
        UIImageOrientation.RightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            break
            
        default:
            break
        }
        
        switch (self.imageOrientation) {
        case UIImageOrientation.UpMirrored,     // EXIF = 2
        UIImageOrientation.DownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
            
        case UIImageOrientation.LeftMirrored,   // EXIF = 5
        UIImageOrientation.RightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
            
        default:
            break
        }
        
        return transform
    }
}
