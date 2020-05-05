//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Riley Worstell on 5/2/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework


class CategoryViewController: UITableViewController {

    var categories = [`Category`]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
          super.viewDidLoad()
            loadCategories()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    
      }
    
    //MARK: - Tableview datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categories[indexPath.row].name
        cell.delegate = self
        let color = UIColor(hexString: categories[indexPath.row].color ?? "#FFFFFF")
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
        return cell
    }
    //MARK: - TableView delegate methosd
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
       
        performSegue(withIdentifier: "goToItems", sender: self)
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    //MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.categories.append(newCategory)
            self.saveCategories()
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
            
        }
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data manipulation method
  
    
    func saveCategories() {
        do {
        try context.save()
        } catch {
            print("error")
        }
        tableView.reloadData()
        }
    
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {        categories = try context.fetch(request) }
            catch {
                print("error")
            }
        tableView.reloadData()
        
        
    }

}

//MARK: - Swipe cell delegate methods


extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Item Deleted")
            self.context.delete(self.categories[indexPath.row]) // context is temporary must saveItems
            self.categories.remove(at: indexPath.row)
            self.saveCategories()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
   
    
}
