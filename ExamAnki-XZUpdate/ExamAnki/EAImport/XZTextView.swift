//
//  XZTextView.swift
//  ExamAnkiTextView
//
//  Created by zxz on 4/9/16.
//  Copyright © 2016 zxz. All rights reserved.
//

import UIKit
public protocol XZTextViewDelegate:NSObjectProtocol {
    func didEndEditing(textView:XZTextView)
}

public class XZTextView: UIView,UITextViewDelegate {
    var topic:FlashTopic? = nil
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var titleHeigthLayout: NSLayoutConstraint!
    
    @IBOutlet weak var bodyBottom: NSLayoutConstraint!
    @IBOutlet weak var bodyTextView: UITextView!

    @IBAction func cancelAction(sender: AnyObject) {
        self.removeFromSuperview()
    }
    @IBAction func confirmAction(sender: AnyObject) {
        self.removeFromSuperview()
        delegate?.didEndEditing(self)
    }
    weak public var delegate:XZTextViewDelegate?
    

    override public func awakeFromNib() {
        super.awakeFromNib()
        titleTextView.delegate = self
        bodyTextView.delegate = self
        addKeyBoardNotify()
        configureTextView()
        dynamicHeightForTextView(titleTextView)
        
    }
    override public func removeFromSuperview() {
        super.removeFromSuperview()
        removeKeyBoardNotify()
    }
    
    func configureTextView() {
        titleTextView.text = ""
        bodyTextView.text = ""
        titleTextView.textAlignment = NSTextAlignment.Natural
        
        titleTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle3)
        bodyTextView.font  = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        let edgeInset = UIEdgeInsetsMake(5, 10, 0, 10)
        titleTextView.textContainerInset = edgeInset
        bodyTextView.textContainerInset  = edgeInset
        titleTextView.textContainer.maximumNumberOfLines = 3
    }
    //MARK: 处理 KeyBorad
    func addKeyBoardNotify(){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(XZTextView.handleKeyboardNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(XZTextView.handleKeyboardNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyBoardNotify(){
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    func handleKeyboardNotification(notification:NSNotification){
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurveValue = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedLongValue
        let animationCurve = UIViewAnimationOptions(rawValue: animationCurveValue)
        
        let keyBoardFrameBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyBoardFrameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let beginFrame = self.convertRect(keyBoardFrameBegin, toView: self.window)
        let endFrame = self.convertRect(keyBoardFrameEnd, toView: self.window)
        
        let originChange = endFrame.origin.y - beginFrame.origin.y
        bodyBottom.constant -= originChange
        
        self.setNeedsUpdateConstraints()
        
        let animationOpts:UIViewAnimationOptions = [animationCurve,.BeginFromCurrentState]
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: animationOpts, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
        
        
        //处理scroll滚动
        let range = bodyTextView.selectedRange
        bodyTextView.scrollRangeToVisible(range)
    }
    
    func dynamicHeightForTextView(textview:UITextView) {
        titleHeigthLayout.constant = 40
        
        let size = textview.sizeThatFits(CGSizeMake(textview.bounds.width, CGFloat.max))
        let height = ceil(size.height) + 5

        titleHeigthLayout.constant = height > 40 ? height : 40
        self.setNeedsUpdateConstraints()
    }
    
    public func textViewDidChange(textView: UITextView) {
        if textView == titleTextView {
            dynamicHeightForTextView(textView)
        }
        
        let rect = titleTextView.textContainer.size
        print(rect)
        
    }

    
    func countingWappedTextLineBreaks(textView:UITextView) -> Int{
        let layoutManager = textView.layoutManager
        var numberOfLines = 0, index = 0,numberOfGlyph = layoutManager.numberOfGlyphs //此处为所有layoutMannager管理的container的行数.
        //container的glyph范围
        //var numberOfGlyphInContainer = layoutManager.glyphRangeForTextContainer(NSTextContainer)
        
        let a = sizeof(NSRange)
        let lineRangePtr:NSRangePointer = NSRangePointer.alloc(a)
        lineRangePtr.initialize(NSRange(location: 0, length: 0))
        while index < numberOfGlyph {
            layoutManager.lineFragmentRectForGlyphAtIndex(index, effectiveRange:lineRangePtr)
            numberOfLines += 1
//            
//            print("\(lineRangePtr)")
//            index = NSMaxRange(lineRangePtr.memory)
//            if lineRangePtr != nil {
//                print("\(lineRangePtr)")
//            }
        }
        
        lineRangePtr.destroy()
        lineRangePtr.dealloc(a)
        return numberOfLines
    }
    
    
}

