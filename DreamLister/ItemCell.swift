//
//  ItemCell.swift
//  DreamLister
//
//  Created by Chris Olson on 7/13/17.
//  Copyright © 2017 Chris Olson. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

  
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var details: UILabel!

    
    
    // This function updates the labels that will display on the UI.
    func configureCell(item: Item) {
        
        title.text = item.title
        price.text = "$\(item.price)"
        details.text = item.details
        thumbImage.image = item.toImage?.image as? UIImage
        
    }
    
}
