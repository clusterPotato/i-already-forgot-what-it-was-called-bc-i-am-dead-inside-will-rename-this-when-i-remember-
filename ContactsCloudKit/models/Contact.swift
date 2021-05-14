//
//  Contact.swift
//  ContactsCloudKit
//
//  Created by Gavin Craft on 5/14/21.
//

import CloudKit
class Contact{
    var name: String
    var phoneNumber: String?
    var emailAddress: String?
    let recordId: CKRecord.ID
    init(name: String, phoneNum:String?, email:String?, recordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.name = name
        self.phoneNumber = phoneNum
        self.emailAddress = email
        self.recordId = recordId
    }
}
extension Contact: Equatable{
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.recordId == rhs.recordId
    }
    convenience init?(record: CKRecord){
        print(record.recordID)
        guard let name = record[ContactStrings.nameIdentifier] as? String else{return nil}
        let phoneNum = record[ContactStrings.phoneNumberIdentifier] as? String
        let email = record[ContactStrings.emailAddressIdentifier] as? String
        self.init(name: name, phoneNum: phoneNum, email: email, recordId: record.recordID)
    }
    
}
extension CKRecord{
    convenience init(_ contact: Contact){
        self.init(recordType: ContactStrings.recordTypeKey, recordID: contact.recordId)
        setValuesForKeys([
            ContactStrings.nameIdentifier           :   contact.name,
            ContactStrings.emailAddressIdentifier   :   contact.emailAddress,
            ContactStrings.phoneNumberIdentifier    :   contact.phoneNumber
        ])
    }
}
class LocalContact: Codable{
    var name: String
    var email: String?
    var phoneNumber: String?
    init(from contact: Contact){
        self.name = contact.name
        self.email = contact.emailAddress
        self.phoneNumber = contact.phoneNumber
    }
}
