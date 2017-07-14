//
//  Item+CoreDataClass.swift
//  DreamLister
//
//  Created by Chris Olson on 7/13/17.
//  Copyright © 2017 Chris Olson. All rights reserved.
//

import Foundation
import CoreData


public class Item: NSManagedObject {
    
    
    // Any time an item is created from the Item entity, this function will be called
    public override func awakeFromInsert() {
        super.awakeFromInsert() // Standard superclss
        
        self.created = NSDate() // When a new item is added to the object context, insert a date right away
    }
    
}
