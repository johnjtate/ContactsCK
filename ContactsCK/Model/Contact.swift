//
//  Contact.swift
//  ContactsCK
//
//  Created by John Tate on 9/28/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import CloudKit

class Contact {
    
    var name: String
    var phoneNumber: String?
    var emailAddress: String?
    let ckRecordID: CKRecord.ID
    
    // designated initializer
    init(name: String, phoneNumber: String, emailAddress: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.ckRecordID = ckRecordID
    }
    
    // convenience initializer (failable) to create a Contact model object from a CKRecord
    convenience init?(ckRecord: CKRecord) {
    
        // unwrap everything
        // no need to unwrap ckRecordID because is guaranteed to exist for a CKRecord
        guard let name = ckRecord[Constants.NameKey] as? String,
            let phoneNumber = ckRecord[Constants.PhoneNumberKey] as? String,
            let emailAddress = ckRecord[Constants.EmailAddressKey] as? String else { return nil }
        
        // call the designated initializer
        // initialize ckRecordID from the CKRecordID
        self.init(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, ckRecordID: ckRecord.recordID)
    }
}

extension CKRecord {
    
    // convenience init to create a CKRecord from a Contact model object
    convenience init(contact: Contact) {
        
        self.init(recordType: Constants.ContactRecordType, recordID: contact.ckRecordID)
        self.setValue(contact.name, forKey: Constants.NameKey)
        self.setValue(contact.phoneNumber, forKey: Constants.PhoneNumberKey)
        self.setValue(contact.emailAddress, forKey: Constants.EmailAddressKey)
    }
}

struct Constants {
    
    static let ContactRecordType = "Contact"
    static let NameKey = "Name"
    static let PhoneNumberKey = "Phone Number"
    static let EmailAddressKey = "Email Address"
}
