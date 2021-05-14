//
//  ContactController.swift
//  ContactsCloudKit
//
//  Created by Gavin Craft on 5/14/21.
//

import Foundation
import CloudKit
class ContactController{
    //MARK: - properties
    static let shared = ContactController()
    let database = CKContainer.default().privateCloudDatabase
    var contacts: [Contact] = []
    weak var delegate: ErrorDelegate?
    
    //MARK: - crud
    ///im not using a closure here because i am not a fan of that data path but i do understand how to do it
    func fetchExistingContacts(completion: @escaping()->Void){
        let fetchAllPredicate = NSPredicate(value: true) //just give me everything for this one
        let query = CKQuery(recordType: ContactStrings.recordTypeKey, predicate: fetchAllPredicate)
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error{
                //max you are welcome. i am cool with whatever for naming
                DispatchQueue.main.async{
                    self.delegate?.presentErrorToUser(localizedErrorString: error.localizedDescription)
                }
                return
            }
            guard let records = records else {return}
            for record in records{
                guard let contact = Contact(record: record) else {continue}
                print(contact.emailAddress)
                self.contacts.append(contact)
            }
            completion()
        }
    }
    func subscribeToRemotes(){
        let subscription = CKQuerySubscription(recordType: ContactStrings.recordTypeKey, predicate: NSPredicate(value: true))
    }
    func createNewContact(named: String, emailAddress: String?, phoneNumber: String?){
        let contact = Contact(name: named, phoneNum: phoneNumber, email: emailAddress)
        saveContactToCloud(contact)
        contacts.append(contact)
    }
    func deleteContact(_ contact: Contact){
        guard let index = contacts.firstIndex(of: contact) else {delegate?.showToast(message: "Contact does not exist in local SOT");return}
        contacts.remove(at: index)
        let deleteOp = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.recordId])
        deleteOp.qualityOfService = .userInteractive
        deleteOp.savePolicy = .changedKeys
        deleteOp.modifyRecordsCompletionBlock = {(records, _, err) in
            if let err = err{
                DispatchQueue.main.async {
                    self.delegate?.presentErrorToUser(localizedErrorString: err.localizedDescription)
                }
                return
            }
            if records?.count == 0{
                DispatchQueue.main.async {
                    self.delegate?.showToast(message: "Delete from cloud successful")
                }
            }
        }
        database.add(deleteOp)
        
    }
    func updateContact(_ contact: Contact, name: String?, phoneNum: String?, emailAddress: String?){
        let record = CKRecord(contact)
        
        print(record.recordID)
        let updateOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        updateOp.savePolicy = .changedKeys
        updateOp.qualityOfService = .userInteractive
        updateOp.modifyRecordsCompletionBlock = {(records, _, error) in
            if let error = error{
                DispatchQueue.main.async {
                    self.delegate?.presentErrorToUser(localizedErrorString: error.localizedDescription)
                }
            }
            guard let record = records?.first else {return}
            guard let updated = Contact(record: record) else {return}
            guard let index = self.contacts.firstIndex(of: contact) else {return}
            self.contacts.remove(at: index)
            self.contacts.insert(updated, at: index)
            
        }
        database.add(updateOp)
    }
    func saveContactToCloud(_ contact: Contact){
        let record = CKRecord(contact)
        database.save(record) { _, error in
            if let error = error{
                DispatchQueue.main.async {
                    self.delegate?.presentErrorToUser(localizedErrorString: error.localizedDescription)
                }
            }
        }
    }
}
