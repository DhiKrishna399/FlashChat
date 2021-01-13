//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.dataSource = self
        tableView.delegate = self
        //How to remove back button
        navigationItem.hidesBackButton = true
        title = Constants.appName
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMessages()
        
    }
    

    
    func loadMessages() {
        
        //.order() method will sort out the messages
        db.collection(Constants.FStore.collectionName)
            .order(by: Constants.FStore.dateField)
            .addSnapshotListener() { (querySnapshot, err) in
            //intialize messages inside snapshot to prevent multiple duplicates being loaded
            self.messages = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for doc in querySnapshot!.documents {
                    print("\(doc.documentID) => \(doc.data())")
                    let data = doc.data()
                    //downcast from Any -> String bc map is in format [String: Any]
                    if  let messageSender = data[Constants.FStore.senderField] as? String, let messageBody = data[Constants.FStore.bodyField] as? String    {
                        let newMessage = Message(sender: messageSender, body: messageBody)
                        self.messages.append(newMessage)
                        
                        //we retrieve the data before it can be set in the viewDidLoad so we must call this method again
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                      
                    }
                    
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        //Current user/message is an optional bc they can be empty
        if let currentMessage = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            
            db.collection(Constants.FStore.collectionName).addDocument(data: [
                Constants.FStore.senderField: messageSender,
                Constants.FStore.bodyField: currentMessage,
                Constants.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print("Error saving data to firestore, \(e)")
                } else {
                    print("Succesful")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                   
                }
                
            }
        }
        
 
        
    }
    
    @IBAction func logoutBtnPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
}

//MARK: - TableViewExtension
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        //We have to cast it as a MessageCell for it to take on the properties we made in the .xib file
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell
        //IndexPath gives us the index and we use this to retrieve the message from the array
        cell.label.text = message.body
        
        //Message from 'me'
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: Constants.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: Constants.BrandColors.purple)
            
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: Constants.BrandColors.purple)
            cell.label.textColor = UIColor(named: Constants.BrandColors.lightPurple)
            
        }
       
        return cell
    }
    
    
}

//MARK: - UITableViewDelegate Extension
extension ChatViewController: UITableViewDelegate {
    
    //Handles presses of indexes
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
