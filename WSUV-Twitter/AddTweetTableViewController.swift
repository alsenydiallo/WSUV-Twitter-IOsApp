//
//  AddTweetTableViewController.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/29/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import UIKit
import Alamofire

class AddTweetTableViewController: UITableViewController {

    @IBOutlet weak var textViewField: UITextView!
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.enableAddTweet == true {
            if let tweet_text = textViewField.text{
                
                let parameters = [
                    "username" : appDelegate.username,
                    "session_token": appDelegate.session_token,
                    "tweet" : tweet_text
                ]
                
                Alamofire.request(kBaseURLString + "/add-tweet.cgi", method:.post, parameters:parameters)
                    .responseJSON{ response in
                        
                        switch(response.result){
                        case .success(let JSON):
                            self.textViewField.resignFirstResponder()
                            let data = JSON as! [String : AnyObject]
                            print(data["tweet"] as! String)
                            self.dismiss(animated: true, completion: {
                                NSLog("dissmissed add view controller")
                                NotificationCenter.default.post(name: kAddTweetNotification, object: nil)
                            })
                        case .failure(let error):
                            if let httpStatusCode = response.response?.statusCode {
                                switch(httpStatusCode) {
                                case 404:
                                    self.displayErrorMessageAlert(error: "404 invalid request, \(error.localizedDescription)")
                                case 500:
                                    self.displayErrorMessageAlert(error: "Server error, \(error.localizedDescription)")
                                default:
                                    self.displayErrorMessageAlert(error: "Error occured, \(error.localizedDescription)")
                                }
                            }
                            
                        }
                }
                
            }
        }// need to loggin first before adding tweet
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.enableAddTweet == true {
            if !textViewField.text.isEmpty {
                let alertC = UIAlertController(title: "Discard changes", message: "Would you like to discard all changes ?" , preferredStyle: .alert)
                alertC.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {_ in
                    self.dismiss(animated: true, completion: nil)
                }))
                alertC.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
                self.present(alertC, animated: true, completion: nil)
            }
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        textViewField.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func displayErrorMessageAlert(error : String) {
        let alertController = UIAlertController(title: "Error message", message: error, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
