//
//  ContactDetailViewController.swift
//  ContactsCK
//
//  Created by John Tate on 9/28/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextLabel: UITextField!
    @IBOutlet weak var phoneNumberTextLabel: UITextField!
    @IBOutlet weak var emailAddressTextLabel: UITextField!
    
    // landing pad for segue
    var contact: Contact? {
        didSet {
            // this protects if the view loads too fast but the landing pad is empty, resulting in updateViews having no contact
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    func updateViews() {
        
        guard let contact = contact else { return }
        nameTextLabel.text = contact.name
        phoneNumberTextLabel.text = contact.phoneNumber ?? ""
        emailAddressTextLabel.text = contact.emailAddress ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - IBActions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
     
        // phone number and email address are optional, but have to guard against blank field for name
        guard let name = nameTextLabel.text, !name.isEmpty, let phoneNumber = phoneNumberTextLabel.text, let emailAddress = emailAddressTextLabel.text else { return }
        
        // here have to differentiate between modifying an existing entry and creating a new entry; if modifying, then there will be a contact on the landing pad
        if let contact = contact {
            
            // update contact
            ContactController.shared.updateContact(contact: contact, withName: name, phoneNumber: phoneNumber, emailAddress: emailAddress) { (success) in
                
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    fatalError("failed to save updated contact")
                }
            }
            
        } else {
            
            // create new contact
            ContactController.shared.createContact(withName: name, phoneNumber: phoneNumber, emailAddress: emailAddress) { (success) in
                
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                     fatalError("failed to create a contact")
                }
            }
        }
    }
}
