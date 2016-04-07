//
//  GMTextAttachment.swift
//  TextkitTest
//
//  Created by Thierry on 16/4/7.
//  Copyright © 2016年 Thierry. All rights reserved.
//

import UIKit

class GMTextAttachment: NSTextAttachment {
    var verticalOffset: CGFloat = 0.0
    
    // To vertically center the image, pass in the font descender as the vertical offset.
    // We cannot get this info from the text container since it is sometimes nil when `attachmentBoundsForTextContainer`
    // is called.
    
    convenience init(_ image: UIImage, verticalOffset: CGFloat = 0.0) {
        self.init()
        self.image = image
        self.verticalOffset = verticalOffset
    }
    
    override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        let height = lineFrag.size.height
        var scale: CGFloat = 1.0;
        let imageSize = image!.size
        
        if (height < imageSize.height) {
            scale = height / imageSize.height
        }
        
        return CGRect(x: 0, y: verticalOffset, width: imageSize.width * scale, height: imageSize.height * scale)
    }
    
}