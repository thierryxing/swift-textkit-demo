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
        let topImage = UIImage.drawWhiteImage(width: self.size.width, height: 20)
        let bottomImage = UIImage.drawWhiteImage(width: self.size.width, height: 20)
        
        let size = CGSize(width: topImage.size.width, height: topImage.size.height + bottomImage.size.height + self.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        topImage.draw(in: CGRect(x:0, y:0, width:size.width, height:topImage.size.height));
        self.draw(in: CGRect(x:0, y:topImage.size.height, width:size.width, height:self.size.height));
        bottomImage.draw(in: CGRect(x:0, y:self.size.height + topImage.size.height, width:size.width, height:bottomImage.size.height));
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
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
        let size:CGSize = CGSize(width:width, height:height);
        UIGraphicsBeginImageContextWithOptions(size, true, 0);
        UIColor.white.setFill()
        UIRectFill(CGRect(x:0, y:0, width:size.width, height:size.height));
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return image
    }
    
    
}
