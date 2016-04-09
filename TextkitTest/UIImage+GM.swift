//
//  GMImage.swift
//  TextkitTest
//
//  Created by Thierry on 16/4/7.
//  Copyright © 2016年 Thierry. All rights reserved.
//

import UIKit

private var remoteUrlAssociationKey: String = ""

extension UIImage {
    
    var remoteUrl: String! {
        get {
            return objc_getAssociatedObject(self, &remoteUrlAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &remoteUrlAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /**
     add top and bottom to image
     
     - returns: UIImage
     */
    func imageWithTopAndBottomBorder() -> UIImage{
        let topImage = UIImage.drawWhiteImage(self.size.width, height: 20)
        let bottomImage = UIImage.drawWhiteImage(self.size.width, height: 20)
        
        let size = CGSizeMake(topImage.size.width, topImage.size.height + bottomImage.size.height + self.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        [topImage.drawInRect(CGRectMake(0, 0, size.width, topImage.size.height))];
        [self.drawInRect(CGRectMake(0, topImage.size.height, size.width, self.size.height))];
        [bottomImage.drawInRect(CGRectMake(0, self.size.height + topImage.size.height, size.width, bottomImage.size.height))];
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     draw a white blank image
     
     - parameter width:
     - parameter height:
     
     - returns: UIImage
     */
    private class func drawWhiteImage(width:CGFloat,height:CGFloat) -> UIImage {
        let size:CGSize = CGSizeMake(width, height);
        UIGraphicsBeginImageContextWithOptions(size, true, 0);
        UIColor.whiteColor().setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
    
    
}
