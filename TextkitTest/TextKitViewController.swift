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
    
    let scrollView:UIScrollView = UIScrollView.init(frame: CGRect.zero)
    let textStorage:NSTextStorage = NSTextStorage()
    let layoutManger: NSLayoutManager = NSLayoutManager()
    let fontArribuates = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
    
    var titleTextView: UITextView = UITextView(frame: CGRect.zero)
    var contentTextView: UITextView = UITextView(frame: CGRect.zero)
    var container: NSTextContainer = NSTextContainer(size: CGSize.zero)
    var textContent: NSMutableAttributedString = NSMutableAttributedString()
    var currentRange: NSRange = NSRange.init(location: 0, length: 0)
    var viewWidth: CGFloat = 0.0
    var viewHeight: CGFloat = 0.0
    var scrollViewContentHeight: CGFloat = 0.0
    
    
    // MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Post"
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        
        self.initKeyboardNotification()
        self.initTitleView()
        self.initTextView()
        self.initToolbar()
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.bounds.width, height:self.scrollViewContentHeight)
        self.view.addSubview(self.scrollView)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Init Function
    func initKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func initTitleView(){
        self.titleTextView = UITextView(frame: CGRect(x:15, y:15, width:self.viewWidth - 30, height:100))
        self.titleTextView.addDashedBorder()
        self.titleTextView.font = UIFont.systemFont(ofSize: 18)
        self.titleTextView.isScrollEnabled = false
        self.scrollView.addSubview(self.titleTextView)
    }
    
    func initTextView(){
        self.container = NSTextContainer(size:CGSize(width:self.viewWidth, height:CGFloat.greatestFiniteMagnitude))
        self.container.widthTracksTextView = true
        self.container.heightTracksTextView = true
        self.layoutManger.addTextContainer(self.container)
        self.textStorage.addLayoutManager(self.layoutManger)
        self.textContent = NSMutableAttributedString(string: "The NSParagraphStyle class and its subclass NSMutableParagraphStyle encapsulate the paragraph or ruler attributes used by the NSAttributedString classes.",
                                                     attributes: fontArribuates)
        self.contentTextView = UITextView(frame: CGRect(x:15, y:self.titleTextView.frame.maxY + 10, width:self.viewWidth-30, height:200), textContainer: self.container)
        self.contentTextView.isScrollEnabled = false
        self.contentTextView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag;
        self.contentTextView.dataDetectorTypes = UIDataDetectorTypes(rawValue: 0)
        self.contentTextView.delegate = self
        
        self.scrollView.addSubview(self.contentTextView)
        self.textStorage.setAttributedString(self.textContent)
        self.scrollViewContentHeight = self.titleTextView.frame.height + self.contentTextView.contentSize.height
    }
    
    func initToolbar(){
        let numberToolbar = UIToolbar(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height:toolbarHeight))
        numberToolbar.items = [
            UIBarButtonItem(title: "Insert Picture", style: UIBarButtonItemStyle.plain, target: self, action: #selector(insertPicture)),
            UIBarButtonItem(title: "Export Plain Text", style: UIBarButtonItemStyle.plain, target: self, action: #selector(exportPlainText))]
        self.contentTextView.inputAccessoryView = numberToolbar
    }
    
    
    //MARK: Toolbar function
    /**
     insert picture in textview
     */
    @objc func insertPicture(){
        self.contentTextView.resignFirstResponder()
        self.textStorage.beginEditing()
        
        let lineBreakAttributeString = NSMutableAttributedString(string: self.lineBreakStr, attributes: fontArribuates);
        let borderImage = UIImage(named: "testImage")!.imageWithTopAndBottomBorder()
        let imageWidth = viewWidth - 40
        let imgAttachment = NSTextAttachment(data: nil, ofType: nil)
        var imgAttachmentString: NSAttributedString
        
        borderImage.remoteUrl = "http://7xjlg5.com1.z0.glb.clouddn.com/1.png"
        imgAttachment.image = borderImage
        imgAttachment.bounds = CGRect(x:0, y:0, width:imageWidth, height:borderImage.size.height*(imageWidth/borderImage.size.width))
        imgAttachmentString = NSAttributedString(attachment: imgAttachment)
        
        let textRange = self.locateCurrentTextRange()
        if textRange.location == 0 || textRange.location > textContent.length {
            self.textContent.append(imgAttachmentString)
            self.textContent.append(lineBreakAttributeString)
        }else{
            let index = textRange.location + textRange.length
            self.textContent.insert(imgAttachmentString, at: index)
            self.textContent.insert(lineBreakAttributeString, at: index + imgAttachmentString.length)
        }
        
        self.contentTextView.attributedText = self.textContent
        self.textStorage.setAttributedString(self.textContent)
        self.textStorage.endEditing()
        
        self.changeViewHeight()
        self.scrollToCursor(range: self.currentRange)
    }
    
    /**
     Export NSAttribute String to Plain Text
     */
    @objc func exportPlainText(){
        let exportTextStorage = NSTextStorage()
        exportTextStorage.setAttributedString(self.textContent)
        exportTextStorage.enumerateAttribute(NSAttributedStringKey.attachment, in: NSMakeRange(0, self.textStorage.length), options:.longestEffectiveRangeNotRequired) { (value, range, stop) in
            if (value != nil) {
                if value is NSTextAttachment{
                    let attachment = value as! NSTextAttachment
                    let imgTag = "<img src='\(attachment.image!.remoteUrl)'/>"
                    exportTextStorage.replaceCharacters(in: range, with: imgTag)
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
        let alertController = UIAlertController(title: "Delete this image?", message:"", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.textStorage.beginEditing()
            self.textContent.deleteCharacters(in: range)
            self.textStorage.setAttributedString(self.textContent)
            self.contentTextView.attributedText = self.textContent
            self.textStorage.endEditing()
            self.changeViewHeight()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Locate current text paragraph range,
     Make sure image always append after text instead of insert in selected text
     */
    func locateCurrentTextRange() -> NSRange{
        var textRange = NSMakeRange(0, 0)
        self.textStorage.enumerateAttributes(in: NSMakeRange(0, textStorage.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            if NSLocationInRange(self.currentRange.location, range)
            {
                textRange = range
                stop.pointee = true
            }
        }
        return textRange
    }
    
    /**
     Scroll to current cursor position
     
     - parameter range:
     */
    func scrollToCursor(range:NSRange){
        let scrollHeight = self.contentTextView.frame.minY + self.caculateContentHeight(withRange: NSMakeRange(0, range.location))
        let finalRect = CGRect(x:1, y:scrollHeight, width:1, height:1);
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
            .attributedText.attributedSubstring(from: range)
            .boundingRect(with: CGSize(width:self.contentTextView.frame.width, height:CGFloat.greatestFiniteMagnitude)
                , options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
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
        
        self.scrollViewContentHeight = originFrame.minY + contentTextViewHeight + naviBarHeight
        self.contentTextView.frame = CGRect(x: originFrame.minX, y: originFrame.minY, width: originFrame.width, height: contentTextViewHeight)
        
        print("contentTextViewHeight : \(contentTextViewHeight)")
        print("scrollViewContentHeight : \(self.scrollViewContentHeight)")
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width, height:self.scrollViewContentHeight)
    }
    
    
    // MARK: UITextView Delegate
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
        self.textContent = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        self.changeViewHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true;
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("textViewDidChangeSelection")
        self.currentRange = textView.selectedRange;
        self.scrollToCursor(range: self.currentRange)
        if self.currentRange.location-1 >= 0 && self.textStorage.length >= self.currentRange.location - 1{
            if let _:NSTextAttachment = self.textStorage.attribute(NSAttributedStringKey.attachment, at: self.currentRange.location-1, effectiveRange: nil) as? NSTextAttachment{
//                print(self.lineBreakStr.characters.count)
                confirmDeleteImage(range: NSMakeRange(self.currentRange.location-1, 1))
            }
        }
    }
    
    
    // MARK: Keyboard notification handler
    @objc func keyboardShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + self.toolbarHeight + 20
        self.scrollView.contentInset = contentInset
    }
    
    @objc func keyboardHide(noti:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
