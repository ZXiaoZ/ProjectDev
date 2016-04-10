//
//  ViewController.swift
//  TableViewNodes
//
//  Created by zxz on 16/3/20.
//  Copyright © 2016年 zxz. All rights reserved.
//
import UIKit
let MainWidth = UIScreen.mainScreen().bounds.width
let MainHeight = UIScreen.mainScreen().bounds.height
let EAFlashCardCellIdentifier = "EAFlashCardCellIdentifier"
let EAFlashCardHeaderViewIdentifier = "EAFlashCardHeaderViewIdentifier"

class EAFlashCarVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,XZTextViewDelegate {
    var tableview:UITableView!
    var showView:XZScrollViewCycle!
    var textView:XZTextView?
    
    var flashTopics:[FlashTopic]{
        return EACardManager.getAllFlashTopics()
    }
    
    
    //MARK: viewController生命周期
    override func loadView() {
        super.loadView()
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubView()
        self.tableview.registerClass(XZHeaderView.self, forHeaderFooterViewReuseIdentifier: EAFlashCardHeaderViewIdentifier)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.tableview.editing = true
        self.tableview.reloadData()
    }
    
    func addSubView(){
        self.tableview = UITableView(frame: self.view.frame, style: .Grouped)
        self.view.addSubview(tableview)
        self.tableview.delegate     = self
        self.tableview.dataSource   = self
        let addBtnItem = UIBarButtonItem(barButtonSystemItem: .Add,
                                         target: self, action: #selector(EAFlashCarVC.addTopic))
        self.navigationItem.rightBarButtonItem = addBtnItem
    }
    //MARK: addTopic and removeTopic Action
    func addTopic(sender:UIButton){
        let alert = UIAlertController(title: "添加主题", message:nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "请输入主题"
            textField.borderStyle = UITextBorderStyle.RoundedRect
        }
        let confirm = UIAlertAction(title: "确认", style: .Default) { [unowned self](action) in
            if (alert.textFields?.first?.text) != nil {
                EACardManager.creatFlashCardTopic(alert.textFields!.first!.text! as NSString)
                self.tableview.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .Cancel) { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        alert.view.setNeedsLayout()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func removeTopic(sender:UILongPressGestureRecognizer){
        if sender.state == .Began {
            let view = sender.view as! XZHeaderView
            let flashTopic = self.flashTopics[view.section]
            let alert = UIAlertController(title: nil, message: "删除此主题?", preferredStyle: .Alert)
            let delAction = UIAlertAction(title: "确认", style: .Default) { [unowned self](action) in
                EACardManager.removeFlashTopic(flashTopic)
                alert.dismissViewControllerAnimated(true, completion: nil)
                self.tableview.reloadData()
            }
            let cancel = UIAlertAction(title: "取消", style: .Cancel) { (action) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(delAction)
            alert.addAction(cancel)
            alert.view.setNeedsLayout()
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("flashTopics.count:\(flashTopics.count)")
        return self.flashTopics.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let header = tableview.headerViewForSection(section) as? XZHeaderView
        if header != nil && header!.isTapped == true {
            if let cards = self.flashTopics[section].flashcards {
                return cards.count
            }
        }
        return 0
    }
    // UITableViewCell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(EAFlashCardCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: EAFlashCardCellIdentifier)
            
        }
        
        let card = self.flashTopics[indexPath.section].flashCardsArray[indexPath.row] as! Card
        cell?.textLabel?.text = card.front
        return cell!;
    }
    // HeaderView 高度40
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {return 40}
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = tableview.dequeueReusableHeaderFooterViewWithIdentifier(EAFlashCardHeaderViewIdentifier) as? XZHeaderView
        if headerView == nil {
            headerView = XZHeaderView(reuseIdentifier: EAFlashCardHeaderViewIdentifier)
        }
        headerView!.contentView.backgroundColor = UIColor.whiteColor()
        headerView!.section = section
        headerView!.textLable.text = self.flashTopics[section].topic
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EAFlashCarVC.tapHeaderView(_:)))
        headerView!.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(EAFlashCarVC.removeTopic(_:)))
        longGesture.minimumPressDuration = 1
        longGesture.requireGestureRecognizerToFail(tapGesture)
        headerView!.addGestureRecognizer(longGesture)
        
        let attrTitle = NSAttributedString(string: "+", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(30)])
        headerView!.addCardBtn.setAttributedTitle(attrTitle, forState: UIControlState.Normal)
        headerView!.addCardBtn.addTarget(self, action: #selector(EAFlashCarVC().addCard(_:)), forControlEvents: .TouchUpInside)
        headerView!.addCardBtn.tag = headerView!.section + 1000
        return headerView!
    }
    // addCard
    func addCard(sender:UIButton){
        let secton = sender.tag - 1000
        let topic = self.flashTopics[secton]
        
        
        //        EACardManager.creatCard(topic, front: "pwd", end: "显示当前目录的路径名")
        //        self.tableview.reloadData()
        addCardTextView()
        self.textView!.topic = topic
        
        
        
        print("addCard:\(topic.topic)")
    }
    func addCardTextView()  {
        self.textView = NSBundle.mainBundle().loadNibNamed("XZTextView", owner: self, options: nil).first as? XZTextView
        UIView.animateWithDuration(0.2,
                                   delay: 0,
                                   options: [],
                                   animations:
            { [unowned self] in
                self.tableview.addSubview(self.textView!)
                self.textView!.delegate = self
                self.creatConstrains()
                self.navigationController?.navigationBarHidden = true
            }, completion: nil)
        
    }
    func  creatConstrains(){
        var constrains = [NSLayoutConstraint]()
        textView!.translatesAutoresizingMaskIntoConstraints = false
        constrains.append(NSLayoutConstraint(item: textView!, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0))
        constrains.append(NSLayoutConstraint(item: textView!, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0))
        constrains.append(NSLayoutConstraint(item: textView!, attribute: .Leading, relatedBy:.Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        constrains.append(NSLayoutConstraint(item: textView!, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraints(constrains)
    }
    // XZTextView delegate
    func didEndEditing(textView: XZTextView) {
        self.navigationController?.navigationBarHidden = false
        let topic = textView.topic

        print("\(textView.titleTextView.text)\n\(textView.bodyTextView.text)")
        EACardManager.creatCard(topic!, front: textView.titleTextView.text, end: textView.bodyTextView.text)
        self.textView = nil
        self.tableview.reloadData()
    }
    //headerView tap
    func tapHeaderView(sender:UIGestureRecognizer){
        let view    = sender.view as! XZHeaderView
        let section = view.section
        var indexPaths = [NSIndexPath]()
        
        let count = self.flashTopics[section].flashcards?.count
        if count == 0 { return }
        for i  in  0...(count!-1) {
            let index = NSIndexPath(forRow: i, inSection: section)
            indexPaths.append(index)
        }
        if  view.isTapped == false {
            view.isTapped =  true
            self.tableview.insertRowsAtIndexPaths(indexPaths, withRowAnimation:.Middle)
        }else{
            view.isTapped =  false
            self.tableview.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }
}
extension EAFlashCarVC {
    //MARK: tableview delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableview.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cards = flashTopics[indexPath.section].flashCardsArray as! Array<Card>
        
        showView = XZScrollViewCycle(frame: CGRectZero,flashCards: cards,currentIndex: indexPath.row)
        let navH = self.navigationController?.navigationBar.height
        let tabH = self.tabBarController?.tabBar.height
        showView.frame = CGRectMake(0, 0, MainWidth, MainHeight - navH! - tabH!-30)
        showView.backgroundColor = UIColor.whiteColor()
        
        addCardView()

    }
    
    // 处理展示页面的弹出
    func addLeftBarItem(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                                style: UIBarButtonItemStyle.Plain,
                                                                target: self, action: #selector(EAFlashCarVC.removeCardView))
    }
    func addCardView() {
        UIView.animateWithDuration(0.2,
                                   delay: 0,
                                   options: [],
                                   animations:
            {[unowned self] in
                self.addLeftBarItem()
                
                self.tableview.addSubview(self.showView)
                
            }, completion: nil)
    }
    func removeCardView() {
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   options: [],
                                   animations:
            {[unowned self] in
                self.showView.removeFromSuperview()
                
            }, completion: nil)
        
        self.navigationItem.leftBarButtonItem = nil
    }
    
    
    //MARK:delete
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let card = self.flashTopics[indexPath.section].flashCardsArray[indexPath.row] as! Card
            EACardManager.removeCard(card)
            
            tableview.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
//            tableview.reloadData()
        }
    }
    
    
    
}

