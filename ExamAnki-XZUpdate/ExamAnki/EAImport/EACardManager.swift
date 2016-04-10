//
//  EACardManager.swift
//  ExamAnki
//
//  Created by zxz on 16/4/5.
//  Copyright © 2016年 kongyunpeng. All rights reserved.
//

import UIKit

extension FlashTopic {
    var flashCardsArray:NSArray {
        let arr = NSArray(array: (self.flashcards?.allObjects)!).sort({
            (a,b)-> Bool in
            let one = a as! Card;let two = b as! Card
            return one.id! > two.id!
            })
        return arr as! [Card]
    }
}
class EACardManager: NSObject {
    // 编辑FlashTopic
    class func creatFlashCardTopic(topic:NSString) -> FlashTopic{
        let cardTopic = XZModelService.sharedModelService.creatManagedObjectInTable("FlashTopic") as! FlashTopic
        cardTopic.addtime = NSDate()
        cardTopic.topic = topic as String
        CoreDataStack.sharedCoreDataStack.saveContext()
        return cardTopic
    }
    class func removeFlashTopic(flashTopic:FlashTopic){
        XZModelService.sharedModelService.removeManagedObject(flashTopic)
        CoreDataStack.sharedCoreDataStack.saveContext()
    }
    class func getAllFlashTopics() -> [FlashTopic] {
        let cardTopics = XZModelService.sharedModelService.getAllManagedObjecsInTable("FlashTopic") as! [FlashTopic]
        return cardTopics
    }
    
    // Card
    class func creatCard(topic:FlashTopic ,front:NSString ,end:NSString) -> Card{
        let card = XZModelService.sharedModelService.creatManagedObjectInTable("Card") as! Card
        card.front = front as String
        card.end = end as String
        card.id = creatID(EAFlashCardTypeCode)
        card.qid = creatID(EAFlashCardTypeCode)
        
        if topic.flashcards == nil {
            topic.flashcards = NSSet()
        }
        topic.flashcards = topic.flashcards!.setByAddingObject(card)
        
        card.topic = topic
        CoreDataStack.sharedCoreDataStack.saveContext()
        return card
    }
    class func removeCard(card:Card){
        XZModelService.sharedModelService.removeManagedObject(card)
        CoreDataStack.sharedCoreDataStack.saveContext()

    }
    
    
    
    
    
    
    
    // 保存修改
    func save(){
        CoreDataStack.sharedCoreDataStack.saveContext()
    }
}
