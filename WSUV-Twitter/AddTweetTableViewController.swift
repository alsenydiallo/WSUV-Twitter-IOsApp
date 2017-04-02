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
            if let tweet = textViewField.text{
                
                let parameters = [
                    "username" : appDelegate.username,
                    "session_token": appDelegate.session_token,
                    "tweet" : tweet
                ]
                
                Alamofire.request(kBaseURLString + "/add-tweet.cgi", method:.post, parameters:parameters)
                    .responseJSON{ response in
                        
                        switch(response.result){
                        case .success(let JSON):
                            let data = JSON as! [String : AnyObject]
                            print(data["tweet"] as! String)
                            break
                        case .failure(let error):
                            print(error)
                        }
                }
                
            }
            self.dismiss(animated: true, completion: nil)
        }// need to loggin first before adding tweet
        else {
            self.dismiss(animated: true, completion: nil)
            print("Error need to login first before adding a tweet")
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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

}
