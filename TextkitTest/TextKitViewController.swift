//
//  TextKitViewController.swift
//  TextkitTest
//
//  Created by Thierry on 16/4/7.
//  Copyright © 2016年 Thierry. All rights reserved.
//

import UIKit

class TextKitViewController: UIViewController, UITextViewDelegate  {
    
    let naviBarHeight: CGFloat = 64.0
    let textViewInset: CGFloat = 10.0
    let toolbarHeight: CGFloat = 50.0
    let singleLineHeight: CGFloat = 40.0
    let lineBreakStr:String = "\n\n"
    
    let scrollView:UIScrollView = UIScrollView.init(frame: CGRectZero)
    let textStorage:NSTextStorage = NSTextStorage()
    let layoutManger: NSLayoutManager = NSLayoutManager()
    let fontArribuates = [NSFontAttributeName: UIFont.systemFontOfSize(16)]
    
    var titleTextView: UITextView = UITextView(frame: CGRectZero)
    var contentTextView: UITextView = UITextView(frame: CGRectZero)
    var container: NSTextContainer = NSTextContainer(size: CGSize.zero)
    var textContent: NSMutableAttributedString = NSMutableAttributedString()
    var currentRange: NSRange = NSRange.init(location: 0, length: 0)
    var viewWidth: CGFloat = 0.0
    var viewHeight: CGFloat = 0.0
    var scrollViewContentHeight: CGFloat = 0.0
    
    
    // MARK: Life Cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Post"
        self.edgesForExtendedLayout = UIRectEdge.None
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.scrollView.backgroundColor = UIColor.blueColor()
        
        self.initKeyboardNotification()
        self.initTitleView()
        self.initTextView()
        self.initToolbar()
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), self.scrollViewContentHeight)
        self.view.addSubview(self.scrollView)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Init Function
    func initKeyboardNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func initTitleView(){
        self.titleTextView = UITextView(frame: CGRectMake(15, 15, self.viewWidth - 30, 100))
        self.titleTextView.addDashedBorder()
        self.titleTextView.font = UIFont.systemFontOfSize(18)
        self.titleTextView.scrollEnabled = false
        self.scrollView.addSubview(self.titleTextView)
    }
    
    func initTextView(){
        self.container = NSTextContainer(size:CGSizeMake(self.viewWidth, CGFloat.max))
        self.container.widthTracksTextView = true
        self.container.heightTracksTextView = true
        self.layoutManger.addTextContainer(self.container)
        self.textStorage.addLayoutManager(self.layoutManger)
        self.textContent = NSMutableAttributedString(string: "The NSParagraphStyle class and its subclass NSMutableParagraphStyle encapsulate the paragraph or ruler attributes used by the NSAttributedString classes.",
                                                     attributes: fontArribuates)
        self.contentTextView = UITextView(frame: CGRectMake(15, CGRectGetMaxY(self.titleTextView.frame) + 10, self.viewWidth-30, 200), textContainer: self.container)
        self.contentTextView.scrollEnabled = false
        self.contentTextView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag;
        self.contentTextView.dataDetectorTypes = UIDataDetectorTypes.None
        self.contentTextView.delegate = self
        
        self.scrollView.addSubview(self.contentTextView)
        self.textStorage.setAttributedString(self.textContent)
        self.scrollViewContentHeight = self.titleTextView.frame.height + self.contentTextView.contentSize.height
    }
    
    func initToolbar(){
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight))
        numberToolbar.items = [
            UIBarButtonItem(title: "Insert Picture", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(insertPicture)),
            UIBarButtonItem(title: "Export Plain Text", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(exportPlainText))]
        self.contentTextView.inputAccessoryView = numberToolbar
    }
    
    
    //MARK: Toolbar function
    /**
     insert picture in textview
     */
    func insertPicture(){
        self.contentTextView.resignFirstResponder()
        self.textStorage.beginEditing()
        
        let lineBreakAttributeString = NSMutableAttributedString(string: self.lineBreakStr, attributes: fontArribuates);
        let borderImage = UIImage(named: "testImage")!.imageWithTopAndBottomBorder()
        let imageWidth = viewWidth - 40
        let imgAttachment = NSTextAttachment(data: nil, ofType: nil)
        var imgAttachmentString: NSAttributedString
        
        borderImage.remoteUrl = "http://7xjlg5.com1.z0.glb.clouddn.com/1.png"
        imgAttachment.image = borderImage
        imgAttachment.bounds = CGRectMake(0, 0, imageWidth, borderImage.size.height*(imageWidth/borderImage.size.width))
        imgAttachmentString = NSAttributedString(attachment: imgAttachment)
        
        let textRange = self.locateCurrentTextRange()
        if textRange.location == 0 || textRange.location > textContent.length {
            self.textContent.appendAttributedString(imgAttachmentString)
            self.textContent.appendAttributedString(lineBreakAttributeString)
        }else{
            let index = textRange.location + textRange.length
            self.textContent.insertAttributedString(imgAttachmentString, atIndex: index)
            self.textContent.insertAttributedString(lineBreakAttributeString, atIndex: index + imgAttachmentString.length)
        }
        
        self.contentTextView.attributedText = self.textContent
        self.textStorage.setAttributedString(self.textContent)
        self.textStorage.endEditing()
        
        self.changeViewHeight()
        self.scrollToCursor(self.currentRange)
    }
    
    /**
     Export NSAttribute String to Plain Text
     */
    func exportPlainText(){
        let exportTextStorage = NSTextStorage()
        exportTextStorage.setAttributedString(self.textContent)
        exportTextStorage.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, self.textStorage.length), options:.LongestEffectiveRangeNotRequired) { (value, range, stop) in
            if (value != nil) {
                if value is NSTextAttachment{
                    let attachment = value as! NSTextAttachment
                    let imgTag = "<img src='\(attachment.image!.remoteUrl)'/>"
                    exportTextStorage.replaceCharactersInRange(range, withString: imgTag)
                    stop.memory = true
                }
            }
        }
        NSLog("%@", exportTextStorage.string)
    }
    
    /**
     Confrim if delete image
     
     - parameter range: image attachment range
     */
    func confirmDeleteImage(range:NSRange){
        self.contentTextView.resignFirstResponder()
        self.contentTextView.selectedRange = NSMakeRange(1, 0)
        let alertController = UIAlertController(title: "Delete this image?", message:"", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.textStorage.beginEditing()
            self.textContent.deleteCharactersInRange(range)
            self.textStorage.setAttributedString(self.textContent)
            self.contentTextView.attributedText = self.textContent
            self.textStorage.endEditing()
            self.changeViewHeight()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Locate current text paragraph range,
     Make sure image always append after text instead of insert in selected text
     */
    func locateCurrentTextRange() -> NSRange{
        var textRange = NSMakeRange(0, 0)
        self.textStorage.enumerateAttributesInRange(NSMakeRange(0, textStorage.length), options: .LongestEffectiveRangeNotRequired) { (value, range, stop) in
            if NSLocationInRange(self.currentRange.location, range)
            {
                textRange = range
                stop.memory = true
            }
        }
        return textRange
    }
    
    /**
     Scroll to current cursor position
     
     - parameter range:
     */
    func scrollToCursor(range:NSRange){
        let scrollHeight = CGRectGetMinY(self.contentTextView.frame) + self.caculateContentHeight(withRange: NSMakeRange(0, range.location))
        let finalRect = CGRectMake(1, scrollHeight, 1, 1);
        print("scrollToCursor : \(scrollHeight)")
        self.scrollView.scrollRectToVisible(finalRect, animated: true)
    }
    
    /**
     Caculate Content Height in specific range
     
     - parameter range
     
     - returns: height
     */
    func caculateContentHeight(withRange range:NSRange) -> CGFloat{
        let contentSize:CGRect = self.contentTextView
            .attributedText.attributedSubstringFromRange(range)
            .boundingRectWithSize(CGSizeMake(self.contentTextView.frame.width, CGFloat.max)
                , options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        print("caculateContentHeight withRange:\(contentSize.height)")
        // Make sure there always a single blank line in bottom
        return contentSize.height +  singleLineHeight
    }
    
    /**
     Change TextView frame height and ScrollView content height
     */
    func changeViewHeight(){
        let originFrame = self.contentTextView.frame
        let contentTextViewHeight = self.caculateContentHeight(withRange: NSMakeRange(0, self.textStorage.length))
        
        self.scrollViewContentHeight = CGRectGetMinY(originFrame) + contentTextViewHeight + naviBarHeight
        self.contentTextView.frame = CGRect(x: CGRectGetMinX(originFrame), y: CGRectGetMinY(originFrame), width: CGRectGetWidth(originFrame), height: contentTextViewHeight)
        
        print("contentTextViewHeight : \(contentTextViewHeight)")
        print("scrollViewContentHeight : \(self.scrollViewContentHeight)")
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), self.scrollViewContentHeight)
    }
    
    
    // MARK: UITextView Delegate
    func textViewDidChange(textView: UITextView) {
        print("textViewDidChange")
        self.textContent = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        self.changeViewHeight()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true;
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        print("textViewDidChangeSelection")
        self.currentRange = textView.selectedRange;
        self.scrollToCursor(self.currentRange)
        if self.textStorage.length>=self.currentRange.location - 1{
            if let _:NSTextAttachment = self.textStorage.attribute(NSAttachmentAttributeName, atIndex: self.currentRange.location-1, effectiveRange: nil) as? NSTextAttachment{
                print(self.lineBreakStr.characters.count)
                confirmDeleteImage(NSMakeRange(self.currentRange.location-1, 1))
            }
        }
    }
    
    
    // MARK: Keyboard notification handler
    func keyboardShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + self.toolbarHeight + 20
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardHide(noti:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInset
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
