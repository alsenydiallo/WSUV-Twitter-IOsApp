//
//  AddTweetTableViewController.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/29/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import UIKit
import Alamofire

class AddTweetTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var textViewField: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        if let tweet_text = textViewField.text{
            
            let parameters = [
                "username" : SSKeychain.password(forService: kWazzuTwitterPassword, account: "username") as String,
                "session_token": SSKeychain.password(forService: kWazzuTwitterPassword, account: "session_token") as String,
                "tweet" : tweet_text
            ]
            
            Alamofire.request(kBaseURLString + "/add-tweet.cgi", method:.post, parameters:parameters)
                .responseJSON{ response in
                    
                    switch(response.result){
                    case .success(_):
                        self.textViewField.resignFirstResponder()
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: kAddTweetNotification, object: nil)
                        })

                    case .failure(_):
                        if let httpStatusCode = response.response?.statusCode {
                            switch(httpStatusCode) {
                            case 404:
                                self.displayErrorMessageAlert(error: "404 invalid request.")
                            case 500:
                                self.displayErrorMessageAlert(error: "Internal server error.")
                            case 503:
                                self.displayErrorMessageAlert(error: "unable to connect to internal database.")
                            default:
                                break
                            }
                        }
                        
                    }
            }
            
        }
    }
    
    func textView(_  textField: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //let newLength = textViewField.text.utf16.count + string.utf16.count - range.length
        let newLength = textViewField.text.characters.count
        NSLog("newLength = \(newLength)")
        characterCountLabel.text =  String(newLength) + String(" /count ")         //change the value of the label
        //return true to allow the change, if you want to limit the number of characters in the text field to just allow up to 25 characters
        return newLength <= 200
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if !textViewField.text.isEmpty {
            let alertC = UIAlertController(title: "Discard changes", message: "Would you like to discard all changes ?" , preferredStyle: .alert)
            alertC.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            alertC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alertC, animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        textViewField.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        characterCountLabel.text = String("0 /count  ")
        textViewField.delegate = self
    }
    
    func displayErrorMessageAlert(error : String) {
        let alertController = UIAlertController(title: "Error message", message: error, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
