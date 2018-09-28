//
//  ContactController.swift
//  ContactsCK
//
//  Created by John Tate on 9/28/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    
    // singleton
    static let shared = ContactController()
    private init() {}
    
    // source of truth
    var contacts: [Contact] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // CRUD functions
    // create/save
    func save(contact: Contact, completion: @escaping (Bool) -> Void) {
        
        let contactRecord = CKRecord(contact: contact)
        publicDB.save(contactRecord) { (record, error) in
            
            // handle the error
            if let error = error {
                print("error saving contact \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // unwrap the record saved to CloudKit and create a Contact model object from it
            guard let record = record, let contact = Contact(ckRecord: record) else { completion(false) ; return }
            // append to the Source of Truth
            self.contacts.append(contact)
            completion(true)
        }
    }
    
    func createContact(withName name: String, phoneNumber: String?, emailAddress: String?, completion: @escaping (Bool) -> Void) {
        
        let contact = Contact(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress)
        save(contact: contact) { (success) in
            completion(success)
        }
    }
    
    // fetch/read
    func fetchAllContactsFromCloudKit(completion: @escaping ([Contact]?) -> Void) {
        
        // query--here we fetch all contacts, although in normal context would want a more specific predicate if this is a network-intensive fetch
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.ContactRecordType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            // handle the error
            if let error = error {
                print("error fetching contacts \(error) \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // unwrap the records returned from CloudKit
            guard let records = records else { return }
            
            // use compactMap to loop through the fetched records and initialize an array of Contact model objects from them; populate the Source of Truth with the contacts
            let contacts = records.compactMap { Contact(ckRecord: $0) }
            self.contacts = contacts
            completion(contacts)
        }
    }

    // modify/update
    func updateContact(contact: Contact, withName name: String, phoneNumber: String?, emailAddress: String?, completion: @escaping (Bool) -> Void) {
        
        // update the properties of the contact
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.emailAddress = emailAddress
        
        // create a CKRecord from the updated contact
        let record = CKRecord(contact: contact)
        // CKModifyRecordsOperation to save the modified contact to CloudKit; note that we do not delete any record here
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        // only save the changed keys
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        // use the highest value of the QualityOfService enum, although .userInitiated would probably be fine also
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
            completion(true)
        }
        
        // have to call self here because we are in a closure
        self.publicDB.add(operation)
        
    }
    
    func delete(contact: Contact, completion: @escaping (Bool) -> Void) {
        
        let recordID = contact.ckRecordID
        publicDB.delete(withRecordID: recordID) { (ckRecordID, error) in
            
            // handle the error
            if let error = error {
                print("error deleting contact \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
        }
        
        // remove the error from the Source of Truth locally; note that index(of: contact) function requires Contact model object to conform to the Equatable protocol
        guard let index = self.contacts.index(of: contact) else { return }
        self.contacts.remove(at: index)
    }
}
