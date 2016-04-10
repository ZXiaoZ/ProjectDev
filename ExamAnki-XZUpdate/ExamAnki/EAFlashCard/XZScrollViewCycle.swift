//
//  XZScrollViewCycle.swift
//  ExamAnki
//
//  Created by zxz on 4/10/16.
//  Copyright © 2016 kongyunpeng. All rights reserved.
//

import UIKit
class XZScrollViewCycle: UIView {
    private let imageViewMaxCount   = 3
    private var scrollView:UIScrollView!
    private var pageControl:UIPageControl!
    private var timer:NSTimer?
    private var cardViews:Array<XZCard> = []
    
    var flashCards:Array<Card> = []
    
    var currentCardIndex = 0
    var nextCardIndex:Int{
        return currentCardIndex.successor() % numberOfPages
    }
    var preCardIndex:Int{
        return (currentCardIndex.predecessor() + numberOfPages) % numberOfPages
    }
    
    
    var numberOfPages:Int {
        if flashCards.count == 0 {
            return 1
        }
        return flashCards.count
    }
    var index:Int = 0 {
        didSet{
            pageControl.currentPage = index
        }
    }
    
    convenience init(frame:CGRect ,flashCards:Array<Card>,currentIndex:Int) {
        self.init(frame:frame)
        self.creatscrollView() //必须在前面
        self.creatPageControl()
        self.pageControl.numberOfPages = self.numberOfPages
        self.flashCards = flashCards
        self.currentCardIndex = currentIndex
        //初始化数据
        cardViews[1].card = flashCards[currentCardIndex]
        cardViews[0].card = flashCards[preCardIndex]
        cardViews[2].card = flashCards[nextCardIndex]
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not implemented")
    }
    
    override func layoutSubviews() {
        self.scrollView.frame          = self.frame
        self.scrollView.contentSize    = CGSizeMake(CGFloat(imageViewMaxCount)*self.width,self.height)
        self.scrollView.contentOffset  = CGPointMake(self.bounds.width, 0)
        
        for i in 0..<3 {
            let view = scrollView.subviews[i]
            view.userInteractionEnabled = true
            view.frame = CGRectMake(CGFloat(i) * scrollView.width, scrollView.y, scrollView.width, scrollView.height)
        }
        
        let pageW: CGFloat = 80
        let pageH: CGFloat = 20
        
        pageControl.frame       = CGRectMake(0, self.height-pageH-44, pageW, pageH)
        pageControl.center.x    = self.width/2.0
    }
    
    //scrollView
    func creatscrollView(){
        scrollView                                  = UIScrollView()
        scrollView.bounces                          = false
        scrollView.showsHorizontalScrollIndicator   = false
        scrollView.showsVerticalScrollIndicator     = false
        scrollView.pagingEnabled                    = true
        scrollView.delegate                         = self
        addSubview(scrollView)
        
        for _ in 0..<3 {
            let cardView = XZCard()
            cardViews.append(cardView)
            
            cardView.backgroundColor = UIColor.whiteColor()
            scrollView.addSubview(cardView)
        }
    }
    
    // PageControl
    func creatPageControl(){
        pageControl                         = UIPageControl()
        pageControl.currentPage             = 0
        pageControl.hidesForSinglePage      = true
        pageControl.userInteractionEnabled  = false
        pageControl.pageIndicatorTintColor  = UIColor.blackColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        addSubview(pageControl)
    }
    
    //MARK: timer & timer action
    func startTimer(){
        self.timer = NSTimer(timeInterval: 3.0, target: self, selector: #selector(XZScrollViewCycle().next), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
    }
    func stopTimer(){
        self.timer?.invalidate()
        timer = nil
    }
    func next(){
        //        print("timer action 'next'")
        //        self.scrollView.setContentOffset(CGPointMake(2.0 * self.scrollView.frame.size.width, 0), animated: true)
    }
    
    //MARK: 更新ScrollView
    
    func updateScrollView(scrollView:UIScrollView){
        let currentPage = Int(scrollView.contentOffset.x / scrollView.width)
        
        switch currentPage {
        case 0:
            currentCardIndex = (currentCardIndex.predecessor() + numberOfPages) % numberOfPages
            
        case 2:
            currentCardIndex = (currentCardIndex.successor()) % numberOfPages
        default:
            break
        }
        
        print(currentCardIndex)
        cardViews[1].card = flashCards[currentCardIndex]
        cardViews[0].card = flashCards[preCardIndex]
        cardViews[2].card = flashCards[nextCardIndex]
        scrollView.contentOffset = CGPointMake(scrollView.width, 0)
    }
    
    
    
    
}
//Mark: UIScrollViewDelegate
extension XZScrollViewCycle:UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.stopTimer()
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startTimer()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.updateScrollView(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
    }
    
}