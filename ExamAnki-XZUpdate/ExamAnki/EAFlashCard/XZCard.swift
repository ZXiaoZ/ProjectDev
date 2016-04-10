//
//  XZCard.swift
//  ExamAnki
//
//  Created by zxz on 4/10/16.
//  Copyright © 2016 kongyunpeng. All rights reserved.
//

import UIKit
class XZCard: UIView {
    var card:Card? = nil {
        willSet {
            self.setNeedsDisplay()
            self.bodyLabel.text = newValue!.front
        }
    }
    let bodyLabel       = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        self.addSubview(bodyLabel)
        
        bodyLabel.frame                 = CGRectMake(5, 5, self.width-10, self.height-10)
        bodyLabel.layer.borderWidth     = 1.0
        bodyLabel.layer.cornerRadius    = 10.0
        bodyLabel.layer.masksToBounds   = true
        bodyLabel.numberOfLines         = 0
        bodyLabel.textAlignment         = NSTextAlignment.Center
        bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle3)
        
        if card != nil {
            bodyLabel.text = self.card!.front
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(XZCard.rollOver(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func rollOver(tap:UITapGestureRecognizer){
        UIView.transitionFromView(self.bodyLabel,
                                  toView: self.bodyLabel,
                                  duration: 1.0,
                                  options:  [UIViewAnimationOptions.TransitionFlipFromRight,
                                            UIViewAnimationOptions.ShowHideTransitionViews],
                                  completion:({ [unowned self] (_:Bool) in self.bodyLabel.text = self.card!.end}))
        
    }
    
}


