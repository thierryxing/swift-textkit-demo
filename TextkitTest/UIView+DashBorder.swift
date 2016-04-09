//
//  UIView+DashBorderViewController.swift
//  TextkitTest
//
//  Created by Thierry on 16/4/8.
//  Copyright © 2016年 Thierry. All rights reserved.
//

import UIKit

extension UIView {
    func addDashedBorder() {
        let color = UIColor.grayColor().CGColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height-1)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 0.5
        shapeLayer.lineJoin = kCALineJoinMiter
        shapeLayer.lineDashPattern = [4,2]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).CGPath
        
        self.layer.addSublayer(shapeLayer)
        
    }
}
