//
//  ContactDetailVC.swift
//  ContactsCloudKit
//
//  Created by Gavin Craft on 5/14/21.
//

import UIKit
class ContactViewController: UIViewController, UITextFieldDelegate{
    //MARK: - iboutlets
    @IBOutlet var phoneNumberField: UITextField!
    @IBOutlet var emailAddressField: UITextField!
    @IBOutlet var nameField: UITextField!
    var contact: Contact?
    
    //MARK: - actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let contact = contact else {return}
        contact.phoneNumber = phoneNumberField.text
        contact.emailAddress = emailAddressField.text
        if let name = nameField.text, !name.isEmpty{
            contact.name = name
        }
        ContactController.shared.updateContact(contact, name: nameField.text, phoneNum: phoneNumberField.text, emailAddress: emailAddressField.text)
        navigationController?.popViewController(animated: true)
    }
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberField.delegate = self
        phoneNumberField.keyboardType = .numberPad
        emailAddressField.delegate = self
        nameField.delegate = self
        if let _ = contact{
            doLoading()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func doLoading(){
        guard let contact = contact else {return}
        if let phoneNum = contact.phoneNumber, !(phoneNum == nil){
            phoneNumberField.text = phoneNum
        }
        if let email = contact.emailAddress, !(email == nil){
            emailAddressField.text = email
        }
        nameField.text = contact.name
    }
}
