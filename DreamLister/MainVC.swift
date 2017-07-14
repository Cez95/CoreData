//
//  ViewController.swift
//  DreamLister
//
//  Created by Chris Olson on 7/13/17.
//  Copyright © 2017 Chris Olson. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate { //NSFRC works with core data to only bring in data that is needed (Think SQL and databases). It is very effieicent at saving memory and boosting performance.

    
    @IBOutlet weak var tableView: UITableView! // This connects the table to the view controller (Always used to instantiate)
    @IBOutlet weak var segment: UISegmentedControl! // This connects the segment to the view controller (Always used to instantiate)
    
    
    
    var controller: NSFetchedResultsController<Item>! // This is like the controller in SQL. Helps move around the database and works to pull out rows of data.
    // Labeling the NSFRC ie <Item> tells it what entity in the database to look for.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        generateTestData()
//        ad.saveContext()
        attemptFetch()
    }
    
////////////////////////////////////////////////////////////////////////////////////////////////////
    // This is where we setup our tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections { //grabbing sections out of the controller
            
            let sectionInfo = sections[section] // grabbing the info out of the sections
            return sectionInfo.numberOfObjects // counting how many rows of infor we have and setting it as the number of rows.
        }
        return 0
    }
    
    // Calling cell for row at, which passes the cell to configureCell, which then refers to the ItemCell file and then calls the configureCell creator on that file.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Uses the configure cell to rebuild new rows
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    
    // cellforrowat passes the cell to this function which then uses the configureCell function on ItemCell file to recreate new rows. 
    func configureCell(cell: ItemCell, indexPath: NSIndexPath) {
        // Updates the cell
        let item = controller.object(at: indexPath as IndexPath)
        cell.configureCell(item: item)
    }
    
    // This tells what to do when a row is selected in the table view.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let objs = controller.fetchedObjects, objs.count > 0 { // Checks to see if there are infact objects selected.
            
            let item = objs[indexPath.row]
            performSegue(withIdentifier: "ItemDetailsVC", sender: item)
            
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            return sections.count
        }
        return 0
    }
    
    
    // Makes all rows at a height of 152.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
////////////////////////////////////////////////////////////////////////////////////////////////////
    
////////////////////////////////////////////////////////////////////////////////////////////////////
    // This is where we perform our data search and specify what we want to pull for data
    
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() // Creating a fetch request var, what we will be fetching, and what to go fetch.
        let dateSort = NSSortDescriptor(key: "created", ascending: false) // This is how we sort the data returned. "created" is an attribute that was in the Item entity
        let priceSort = NSSortDescriptor(key: "price", ascending: true) // Sorts the data retreived based on price attribute.
        let titleSort = NSSortDescriptor(key: "title", ascending: true) // Sorts the data retreived based on the title attribute.
        
        // This determines how we organize the presented results on the segment bar at the top of the UI.
        if segment.selectedSegmentIndex == 0 {
            
            fetchRequest.sortDescriptors = [dateSort] // This calls to sort by date
            
        } else if segment.selectedSegmentIndex == 1 {
            
            fetchRequest.sortDescriptors = [priceSort] // This calls to sort by price
            
        } else if segment.selectedSegmentIndex == 2 {
            
            fetchRequest.sortDescriptors = [titleSort] // This calls to sort by title
        }
            
   
        
        // Returns a fetch request controller used given the parameters passed in. Remember: 'managedObjectContext: context' comes from AppDelegate and is the shortcut we made to access its function. 
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        do {
            // This executes our fetch on the data.
            try controller.performFetch() // Because a ()throw is noted, it means an error can occur so a do/catch is needed.
        } catch {
// This will catch an error if one occurs. In a do/catch statement, this is typical syntax.
            let error = error as NSError
            print("\(error)")
        }
    }
////////////////////////////////////////////////////////////////////////////////////////////////////
   
    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        attemptFetch()
        tableView.reloadData()
        
        
    }

    
////////////////////////////////////////////////////////////////////////////////////////////////////
    // Essential Core Data functions
    
    // This function is needed to upadete data as what is being searched chages. This does the updating automatically
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    // After we have updated the data with what we needed, we then end the updats. 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
    // This is for the functionality we have with our data on the UI
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        
        // This case is for when we create a new item and save it
        case.insert:
            // This says, when we create a new item insert it at the end of the table and fade it in (animation)
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        // This case is for when we delete an item from our list.
        case.delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
            
        // This is for when you click on an existing item and want to update it.
        case.update:
            if let indexPath = indexPath {
                // let cell is the new cell we want to create
                let cell = tableView.cellForRow(at: indexPath) as! ItemCell
                // Refers to the ItemCell view file
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
            
        // This is for when you move an item around in the table. It delete it from current position and then inserts it in the new positon specified.
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }
////////////////////////////////////////////////////////////////////////////////////////////////////

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // Getting ready for the segue.
        if segue.identifier == "ItemDetailsVC" {
            if let destination = segue.destination as? ItemDetailsVC { // Sets the destination of the segue.
                if let item = sender as? Item { // Creates a new entity Item.
                    destination.itemToEdit = item // Assigns item to itemTOEdit on the itemdetialsvc page. 
                }
            }
        }
    }
////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // This generates the data
    func generateTestData() {
        let item = Item(context: context)
        item.title = "MacBook Pro"
        item.price = 1800
        item.details = "Really sleek and shiny and cooooool. I love this shit"
        
        let item2 = Item(context: context)
        item2.title = "Dre Beats"
        item2.price = 500
        item2.details = "Really sleek and shiny and cooooool. I love this shit"
        
        let item3 = Item(context: context)
        item3.title = "Tesla Model S"
        item3.price = 180000
        item3.details = "This car is amazing, One day it will be mine"
        
    }
}




