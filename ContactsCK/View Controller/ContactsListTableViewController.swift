//
//  ContactsListTableViewController.swift
//  ContactsCK
//
//  Created by John Tate on 9/28/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class ContactsListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fetch all contacts when the view loads
        ContactController.shared.fetchAllContactsFromCloudKit { (contacts) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // resource-intensive method to do this, but forces tableView to update
        ContactController.shared.fetchAllContactsFromCloudKit { (contacts) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ContactController.shared.contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let contact = ContactController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        return cell
    }
   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let contact = ContactController.shared.contacts[indexPath.row]
            
            // delete the contact from the local Source of Truth and CloudKit
            ContactController.shared.delete(contact: contact) { (success) in
                if success {
                    print("successfully deleted contact")
                } else {
                    
                }
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContactDetail" {
            let destinationVC = segue.destination as? ContactDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let contact = ContactController.shared.contacts[indexPath.row]
            destinationVC?.contact = contact
        }
    }
}
