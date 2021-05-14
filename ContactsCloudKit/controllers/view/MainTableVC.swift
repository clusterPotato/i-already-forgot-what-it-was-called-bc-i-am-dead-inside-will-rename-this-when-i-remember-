//
//  MainTableVC.swift
//  ContactsCloudKit
//
//  Created by Gavin Craft on 5/14/21.
//

import UIKit
class InitialTableViewController: UITableViewController, UISearchBarDelegate{
    //MARK: - iboutlets
    @IBOutlet var searchBar: UISearchBar!
    var dataSource: [Contact]{
        get{
            return isSearching ? results : ContactController.shared.contacts
        }
    }
    var results: [Contact] = []
    var isSearching = false
    override func viewDidLoad() {
        super.viewDidLoad()
        ContactController.shared.delegate = self
        searchBar.delegate = self
        ContactController.shared.fetchExistingContacts {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    //MARK: - data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (view.bounds.height/8)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell else {return UITableViewCell()}
        cell.contact = dataSource[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            DispatchQueue.main.async {
                ContactController.shared.deleteContact(self.dataSource[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    //MARK: - actions
    @IBAction func addButtonPressed(_ sender: Any) {
        presentAddAlert()
    }
    
    //MARK: - function
    func presentAddAlert(){
        let alert = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in //0
            textField.placeholder = "ContactName"
        }
        alert.addTextField{textField in //1
            textField.placeholder = "PhoneNumber"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in //2
            textField.placeholder = "Email Address"
            textField.keyboardType = .emailAddress
        }
        let calcelAction = UIAlertAction(title: "Calcel", style: .cancel) { _ in
            //nothing i just like all my completions to have body
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let name = alert.textFields![0].text, !name.isEmpty else {return}
            let number = alert.textFields![1].text
            let email = alert.textFields![2].text
            ContactController.shared.createNewContact(named: name, emailAddress: email, phoneNumber: number)
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
        alert.addAction(addAction)
        alert.addAction(calcelAction)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentDetails"{
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            guard let destinationVC = segue.destination as? ContactViewController else {return}
            destinationVC.contact = dataSource[indexPath.row]
            //destinationVC.doLoading()
        }
    }
    //MARK: - searchBar functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            isSearching = false
        }
        else{
            isSearching = true
            results = []
            for contact in ContactController.shared.contacts{
                if contact.name.contains(searchText){
                    results.append(contact)
                }
            }
        }
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
