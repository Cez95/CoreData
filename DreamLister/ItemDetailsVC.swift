//
//  ItemDetailsVC.swift
//  DreamLister
//
//  Created by Chris Olson on 7/13/17.
//  Copyright © 2017 Chris Olson. All rights reserved.
//

import UIKit
import CoreData
class ItemDetailsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var storePicker: UIPickerView!
    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var priceField: CustomTextField!
    @IBOutlet weak var detailsField: CustomTextField!
    @IBOutlet weak var thumbImage: UIImageView!
    
    
    var stores = [Store]()
    var itemToEdit: Item? // We save this variable as an optional variable (?) because there will be no gaurantee that we are going to edit.
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // This hides the text in the navigation bar back button and leaves just the back arrow. 
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        storePicker.delegate = self
        storePicker.dataSource = self
        
//        
//        let store = Store(context: context) // context is the data you pull from the databse that searches for the Store entity.
//        store.name = "Best Buy"
//        let store2 = Store(context: context)
//         store2.name = "Tesla-Dship"
//        let store3 = Store(context: context)
//        store3.name = "Amazon"
//        let store4 = Store(context: context)
//        store4.name = "Target"
//        let store5 = Store(context: context)
//        store5.name = "Walmart"
//        let store6 = Store(context: context)
//        store6.name = "Craigs-List"
//        
//        ad.saveContext()
        getStores()
        
        // This is how we check if we are editing or not
        if itemToEdit != nil {
            loadItemData() // If we pass in an item to itemToEdit, this loads that items data.
        }
        
    }

/////////////////////////////////////////////////////////////////////////////////////////
    // Standared methods to use the UIPickerview
    
    // This determines the title for the picker view rows
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        let store = stores[row] // Pulls each store entity from the array of store.
        return store.name // Sets the name of the store based on the name attribute of the store entity.
    }
    
    // This determins how many rows will be in the pickerview
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stores.count
    }
    
    // This determines how many columns will be in the picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // When we select a row in the pickerview, this code determines what happens
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
/////////////////////////////////////////////////////////////////////////////////////////
    
/////////////////////////////////////////////////////////////////////////////////////////
    // This is where we fetch the data for our stores.
    
    func getStores() {
        let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
        
        do {
            self.stores = try context.fetch(fetchRequest) // This tells it to search for the Store entity
            self.storePicker.reloadAllComponents() // This reloads all components inside the store picker
        } catch {
            
        }
        
        
        
    }
    
/////////////////////////////////////////////////////////////////////////////////////////
    // This takes the data from the text fields and saves it to the database. This can be powerfull for user data storage!!!
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        var item: Item!
        
        // Handles saving the selected image to our database.
        let picture = Image(context: context)
        picture.image = thumbImage.image
        
        
        // Handles item editing
        if itemToEdit == nil {
            
            item = Item(context: context)
            
        } else {
            
            item = itemToEdit
            
        }
        
        item.toImage = picture

        
        // Handles item creating
        if let title = titleField.text {
            item.title = title
        }
        
        if let price = priceField.text {
            item.price = (price as NSString).doubleValue // This converts a string into a double
        }
        
        if let description = detailsField.text {
            item.details = description
        }
        
        // Assign store we selected
        item.toStore = stores[storePicker.selectedRow(inComponent: 0)] // item.toStore is the relationship between the two entitys.
        
        ad.saveContext()
        
        _ = navigationController?.popViewController(animated: true) // This returns us to the main view after we press save.
    }
/////////////////////////////////////////////////////////////////////////////////////////
    
/////////////////////////////////////////////////////////////////////////////////////////
    // Loads the item data for editing
    
    func loadItemData() {
        
        if let item = itemToEdit {
            titleField.text = item.title
            priceField.text = "$\(item.price)"
            detailsField.text = item.details
            thumbImage.image = item.toImage?.image as? UIImage
            
            // This will determine the store -> item relationship.
            if let store = item.toStore {
                
                // Were creating a while loop starting at 0 and looping through the stores array until it ends or we find the right store.
                var index = 0
                repeat {
                    let s = stores[index] // setting s equal to each entity in stores.
                    if s.name == store.name{ // If the name of the individual entity mathes the store name we have a match.
                        storePicker.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                    index += 1
                } while (index < stores.count) // This ends the loop if index equals entitys in stores.
            }
        }
    }
/////////////////////////////////////////////////////////////////////////////////////////
    
/////////////////////////////////////////////////////////////////////////////////////////
    // Deleting Items
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        
        //Checks to see if we passed an existing object over
        if itemToEdit != nil { // means "If we have something"
            context.delete(itemToEdit!) // These delete the item we selected.
            ad.saveContext()
        }
        _ = navigationController?.popViewController(animated: true)
    }
/////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////
    // This uploads the images when we select the image button. 
    @IBAction func addImage(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    // This allows us to access our camera roll and set an image inside the camera roll to the new image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            thumbImage.image = img
        }
        imagePicker.dismiss(animated: true, completion: nil) // Dismisses the camera roll after selection is made. 
    }
/////////////////////////////////////////////////////////////////////////////////////////
    
    
    
}
