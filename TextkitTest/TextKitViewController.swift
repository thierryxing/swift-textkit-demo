//
//  TextKitViewController.swift
//  TextkitTest
//
//  Created by Thierry on 16/4/7.
//  Copyright © 2016年 Thierry. All rights reserved.
//

import UIKit

class TextKitViewController: UIViewController, UITextViewDelegate, NSTextStorageDelegate  {

    let textStorage:NSTextStorage = NSTextStorage()
    let layoutManger = NSLayoutManager()
    let textViewInset:CGFloat = 10.0
    let toolbarHeight:CGFloat = 50.0
    
    var container:NSTextContainer?
    var textContent:NSMutableAttributedString = NSMutableAttributedString(string: "The NSParagraphStyle class and its subclass NSMutableParagraphStyle encapsulate the paragraph or ruler attributes used by the NSAttributedString classes.", attributes: nil);
    var textView:UITextView?
    var range:NSRange = NSRange.init(location: 0, length: 0)
    var viewWidth:CGFloat? = nil
    var viewHeight:CGFloat? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWidth = self.view.frame.size.width
        viewHeight = self.view.frame.size.height
        
        self.addKeyboardNotification()
        self.initTextView()
        self.initToolbar()
    }
    
    func addKeyboardNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func initTextView(){
        container = NSTextContainer(size:CGSizeMake(viewWidth!, CGFloat.max))
        container!.widthTracksTextView = true;
        layoutManger.addTextContainer(container!)
        textStorage.addLayoutManager(layoutManger)
        textStorage.delegate = self
        
        textView = UITextView(frame: self.view.bounds, textContainer: container);
        textView?.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        textView?.scrollEnabled = true;
        textView?.textContainerInset = UIEdgeInsetsMake(textViewInset, textViewInset, 0, textViewInset)
        textView?.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag;
        textView?.dataDetectorTypes = UIDataDetectorTypes.None
        textView?.delegate = self
        textView?.editable = true
        textView?.selectable = true
        self.view.addSubview(textView!)
        
        textStorage.setAttributedString(textContent);
    }
    
    func initToolbar(){
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight))
        numberToolbar.barStyle = UIBarStyle.Default
        numberToolbar.items = [
            UIBarButtonItem(title: "Insert Picture", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(insertPicture)),
            UIBarButtonItem(title: "Export Plain Text", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(exportPlainText))]
        numberToolbar.sizeToFit()
        textView!.inputAccessoryView = numberToolbar
    }
    
    
    //MARK: Toolbar function
    /**
     insert picture in textview
     */
    func insertPicture(){
        textStorage.beginEditing()
        let image = GMImage(data: UIImagePNGRepresentation(UIImage(named: "testImage")!)!)
        // set remote url, cause you may want to send it to server
        image?.remoteUrl = "http://7xjlg5.com1.z0.glb.clouddn.com/1.png"
        let imgAttachment = NSTextAttachment(data: nil, ofType: nil)
        let imageWidth = viewWidth!-textViewInset*3
        let blankString = NSMutableAttributedString(string: "\n\n", attributes: nil)
        imgAttachment.image = image
        imgAttachment.bounds = CGRectMake(0, 0, imageWidth, image!.size.height*(imageWidth/image!.size.width))
        
        let imgAttachmentString = NSAttributedString(attachment:imgAttachment)
        
        if range.location==0 || range.location>textContent.length {
            textContent.appendAttributedString(blankString)
            textContent.appendAttributedString(imgAttachmentString)
            textContent.appendAttributedString(blankString)
        }else{
            textContent.insertAttributedString(blankString, atIndex: range.location)
            textContent.insertAttributedString(imgAttachmentString, atIndex: range.location+blankString.length)
            textContent.insertAttributedString(NSMutableAttributedString(string: "\n\n", attributes: nil), atIndex: range.location+imgAttachmentString.length+blankString.length)
        }
        textStorage.setAttributedString(textContent)
        textStorage.endEditing()
        textView!.scrollRangeToVisible(NSMakeRange(textView!.attributedText.length, 0))
    }
    
    func exportPlainText(){
        let exportTextStorage = NSTextStorage()
        exportTextStorage.setAttributedString(textContent)
        exportTextStorage.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, textStorage.length), options:.LongestEffectiveRangeNotRequired) { (value, range, stop) in
            if (value != nil) {
                if value is NSTextAttachment{
                    let attachment = value as! NSTextAttachment
                    let imgTag = "<img src='\((attachment.image as! GMImage).remoteUrl)'/>"
                    exportTextStorage.replaceCharactersInRange(range, withString: imgTag)
                }
            }
        }
        NSLog("%@", exportTextStorage.string)
    }
    
    
    // MARK: textView Delegate
    func textViewDidChange(textView: UITextView) {
        textContent = textView.attributedText.mutableCopy() as! NSMutableAttributedString
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        textView.scrollRangeToVisible(range)
        return true;
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        range = textView.selectedRange;
        if textStorage.length>=range.location-1{
        if let _:NSTextAttachment = textStorage.attribute(NSAttachmentAttributeName, atIndex: range.location-1, effectiveRange: nil) as? NSTextAttachment{
                confirmDeleteImage(NSMakeRange(range.location-1, 1))
            }
        }
    }
    
    func confirmDeleteImage(range:NSRange){
        textView?.resignFirstResponder()
        let alertController = UIAlertController(title: "Delete this image?", message:"", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.textStorage.beginEditing()
            self.textContent.deleteCharactersInRange(range)
            self.textStorage.setAttributedString(self.textContent)
            self.textStorage.endEditing()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: keyboard Event handle
    func keyboardShow(noti:NSNotification){
        let userInfo:Dictionary = noti.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        textView?.frame = CGRectMake(0, 0, viewWidth!, viewHeight! - keyboardSize.height - 10)
    }
    
    func keyboardHide(noti:NSNotification){
        textView?.frame = self.view.bounds
    }
    
    
    // MARK: lifecycle
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
