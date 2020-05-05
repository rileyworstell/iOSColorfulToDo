//
//  ViewController.swift
//  Todoey
//
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: UITableViewController {
    
   // var itemArray = ["Find Mike", "Buy Eggos", "Destroy Monster"]
    var itemArray = [Item]()
  //  var color = UIColor.randomFlat()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    // context is how we interact with Core Data
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  


    override func viewDidLoad() {
        super.viewDidLoad()
      print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        
    }

//MARK - Tableview Datasource Methods
    // the following code is what actually gets the items from the array to appear on the screen
    // below function actually gets number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    // this returns the cell of each
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell") as! SwipeTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        print(indexPath.row)
        print(itemArray.count)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        if let color = UIColor(hexString: selectedCategory!.color!)!.darken(byPercentage:
            (CGFloat(indexPath.row) / CGFloat(itemArray.count)) * 0.7
            ) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        
        // value = condition ? valueiftrue: valueiffalse
        cell.accessoryType = item.done ? .checkmark : .none
        
     
        return cell
    }


//MARK - TableView Delegate Methods

    // this function is triggered when a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        // this line would change title to completed   //itemArray[indexPath.row].setValue("Completed", forKey: "Title")
        
        //update done boolean
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
       
//       context.delete(itemArray[indexPath.row]) // context is temporary must saveItems
 //       itemArray.remove(at: indexPath.row)
        self.saveItems()
      
        
        // this makes it flash gray when clicked instead of staying gray below
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //Mark - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New To Do Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // below append to array\
            
           
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            // saves to user defaults (phone data)
            
            self.saveItems()
           
        }
        // add textUI to popup code below triggersimmedietely on clicking add
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        
    }
    
    // save item to databse
    func saveItems() {
                   do {
                    try context.save()
                       } catch {
                       print("error")
                       }
        
        // reload data so that it actually shows on the screen
                   self.tableView.reloadData()
    }
    
    // Load items from database
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
        itemArray = try context.fetch(request)
        
        } catch {
            print("error")
        }
        tableView.reloadData()
    }
    
 
    
}
//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
      
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request, predicate: predicate)
        
       
        
     }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}



//MARK: - Swipe cell delegate methods


extension TodoListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Item Deleted")
            self.context.delete(self.itemArray[indexPath.row]) // context is temporary must saveItems
            self.itemArray.remove(at: indexPath.row)
            self.saveItems()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
}
