//
//  CustomContactCell.swift
//  ContactsCloudKit
//
//  Created by Gavin Craft on 5/14/21.
//

import UIKit
class ContactCell: UITableViewCell{
    //MARK: - eyebeeowtlets
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneNumLabel: UILabel!
    @IBOutlet var emailAddressLabel: UILabel!
    var contact: Contact?{
        didSet{
            loadUpThoseViewBoys()
        }
    }
    //MARK: - functions
    func loadUpThoseViewBoys(){
        guard let contact = contact else {return}
        nameLabel.text = contact.name
        if let num = contact.phoneNumber{
            phoneNumLabel.text = num
        }
        if let email = contact.emailAddress{
            emailAddressLabel.text = email
        }
    }
}
