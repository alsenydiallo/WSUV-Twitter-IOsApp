//
//  TweetsTableViewController.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/23/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import UIKit
import Alamofire

class TweetsTableViewController: UITableViewController {
 
    /******************* Text attributes *******************************/
    lazy var tweetDateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    lazy var tweetBodyAttributes : [String : AnyObject] = {
        let textStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.lineBreakMode = .byWordWrapping
        textStyle.alignment = .left
        let bodyAttributes = [
            NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
            NSForegroundColorAttributeName : UIColor.black,
            NSParagraphStyleAttributeName : textStyle
        ]
        return bodyAttributes
    }()
    
    let tweetTitleAttributes = [
        NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
        NSForegroundColorAttributeName : UIColor.purple
    ]
    
    /******************* variable declaration ***************************/
    lazy var tweets = { () -> [Tweet] in
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.tweets
    }()
    
    var tweetAttributedStringMap : [Tweet : NSAttributedString] = [:]
    
    func attributedStringForTweet(_ tweet : Tweet) -> NSAttributedString {
        let attributedString = tweetAttributedStringMap[tweet]
        if let string = attributedString { // already stored?
            return string
        }
        let dateString = tweetDateFormatter.string(from: tweet.date as Date)
        let title = String(format: "%@ - %@\n", tweet.username, dateString)
        let tweetAttributedString = NSMutableAttributedString(string: title, attributes: tweetTitleAttributes)
        let bodyAttributedString = NSAttributedString(string: tweet.tweet as String, attributes: tweetBodyAttributes)
        tweetAttributedString.append(bodyAttributedString)
        tweetAttributedStringMap[tweet] = tweetAttributedString
        return tweetAttributedString
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        /*NotificationCenter.default.addObserver(
            forName: kAddTweetNotification,
            object: nil,
            queue: nil) { (note : Notification) -> Void in
                if !self.refreshControl!.isRefreshing {
                    self.refreshControl!.beginRefreshing()
                    self.refreshTweets(self)
                }
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return (appDelegate.tweets.count)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweet", for: indexPath)

        // Configure the cell...
        let tweet = self.tweets[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0 // multi-line label
        cell.textLabel?.attributedText = attributedStringForTweet(tweet)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexpath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    /*
        Refresh action inplementation. refresh is trigered on pull down gesture
     */
    @IBAction func refreshTweets(_ sender: UIRefreshControl) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        let lastTweetDate = appDelegate.lastTweetDate()
        let dateStr = dateFormatter.string(from: lastTweetDate as Date)
        
        // format date string from latest stored tweet...
        Alamofire.request(kBaseURLString + "/get-tweets.cgi", method: .get, parameters: ["date": dateStr]).responseJSON{ response in
            
            switch(response.result) {
            case .success(let JSON):
                NSLog("request successfull")
                let dict = JSON as! [String : AnyObject]
                let tweets = dict["tweets"] as! [[String : AnyObject]]
                
                for tweet in tweets {
                    let isdeleted = tweet["isdeleted"] as! Int
                    if isdeleted == 0 {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                        let someDateTime = formatter.date(from: tweet["time_stamp"] as! String)
                    
                        let t = Tweet(tweet_id:tweet["tweet_id"] as! Int, username:tweet["username"] as! String, isDeleted:isdeleted, tweet:tweet["tweet"] as! NSString, date:someDateTime!)
                        
                        appDelegate.tweets.append(t)
                    }
                    else{
                        //XXX implent delete tweet
                    }
                }
                appDelegate.tweets.sort(by: {$0.date > $1.date})
                self.tableView.reloadData() // force table-view to be updated
                self.refreshControl?.endRefreshing()
                
            case .failure(let error):
                let message : String
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 404:
                        NSLog("404 invalid request")
                    case 500:
                        message = "Server error (my bad)"
                        NSLog("request failled: \(message)")
                    default:
                        NSLog("Error occured")
                        break
                    }
                    
                } else { // probably network or server timeout
                    message = error.localizedDescription
                }
                // ... display alert with message ..
                self.refreshControl?.endRefreshing()
            }
        }
    }
    /******************************************** END of RefreshAction ************************************/
    
    /*
        Manage account menu
     */
    @IBAction func manageAccount(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Manage Account", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Register user alert
        alertController.addAction(UIAlertAction(title: "Register", style: .default, handler: { _ in

            let alertC = UIAlertController(title: "Register", message: "Please chose a username & paswword", preferredStyle: .alert)
            
            alertC.addTextField { (textField : UITextField) -> Void in
                textField.placeholder = "Username"
            }
            alertC.addTextField { (textField : UITextField) -> Void in
                textField.isSecureTextEntry = true
                textField.placeholder = "Password"
            }
            
            alertC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alertC.addAction(UIAlertAction(title: "Register", style: .default, handler: { _ in
                let usernameTextField = alertC.textFields![0]
                let passwordTextField = alertC.textFields![1]
                
                // ... check for empty textfields
                if let username = usernameTextField.text {
                    if let password = passwordTextField.text {
                        self.registerUser(username, password: password)
                    }
                }
            }))
            
            self.present(alertC, animated: true, completion: nil)
        }))
        
        // Login user alert
        alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
            
            let alertC = UIAlertController(title: "Login", message: "Please login", preferredStyle: .alert)
            
            alertC.addTextField { (textField : UITextField) -> Void in
                textField.placeholder = "Username"
            }
            alertC.addTextField { (textField : UITextField) -> Void in
                textField.isSecureTextEntry = true
                textField.placeholder = "Password"
            }
            
            alertC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alertC.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
                let usernameTextField = alertC.textFields![0]
                let passwordTextField = alertC.textFields![1]
                
                // ... check for empty textfields
                if let username = usernameTextField.text {
                    if let password = passwordTextField.text {
                        self.loginUser(username, password: password)
                    }
                }
            }))
            
            self.present(alertC, animated: true, completion: nil)
        }))
        
        // Logout user alert
        alertController.addAction(UIAlertAction(title: "Logout", style: .default, handler: { _ in
            
            let alertC = UIAlertController(title: "Logout", message: "Please logout", preferredStyle: .alert)
            
            alertC.addTextField { (textField : UITextField) -> Void in
                textField.placeholder = "Username"
            }
            alertC.addTextField { (textField : UITextField) -> Void in
                textField.isSecureTextEntry = true
                textField.placeholder = "Password"
            }
            
            alertC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alertC.addAction(UIAlertAction(title: "Logout", style: .default, handler: { _ in
                let usernameTextField = alertC.textFields![0]
                let passwordTextField = alertC.textFields![1]
                
                // ... check for empty textfields
                if let username = usernameTextField.text {
                    if let password = passwordTextField.text {
                        self.logoutUser(username, password: password)
                    }
                }
            }))
            self.present(alertC, animated: true, completion: nil)
        }))
        
        // Reset user password
        alertController.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (UIAlertAction) -> Void in
            //XXX add handler code
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    /*
        Register helper function.
    */
    func registerUser(_ username:String, password:String){
        NSLog("server time out: \(username)")
        NSLog("server time out: \(password)")
        
        let urlString = kBaseURLString + "/register.cgi"
        let parameters = [
            "username" : username, // username and password
            "password" : password, // obtained from user
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler:  {response in
            switch(response.result) {
            case .success(let JSON):
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let dict = JSON as! [String : AnyObject]
                appDelegate.username = username
                appDelegate.session_token = dict["session_token"] as! String
                print(appDelegate.session_token)
                self.navigationController?.title = appDelegate.username
                appDelegate.enableAddTweet = true
                // save username
                // save password and session_token in keychain
                // enable "add tweet" button
                // change title of controller to show username, etc...
            case .failure(let error):
                print(error)
                break
                // inform user of error
            }})
    }
    
    
    /*
        login helper function
    */
    func loginUser(_ username:String, password:String){
        NSLog("server time out: \(username)")
        NSLog("server time out: \(password)")
        
        let urlString = kBaseURLString + "/login.cgi"
        let parameters = [
            "username" : username, // username and password
            "password" : password, // obtained from user
            "action" : "login"
        ]
        
        Alamofire.request(urlString, method:.post, parameters:parameters)
            .responseJSON(completionHandler: { response in
                switch(response.result){
                case .success(let JSON):
                    let dict = JSON as! [String : AnyObject]
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.username = username
                    appDelegate.session_token = dict["session_token"] as! String
                    print(appDelegate.session_token)
                    appDelegate.enableAddTweet = true
                    //SSKeychain.setPassword(password, forService: service, account: username)
                case .failure(let error):
                    print(error)
                }
            })
    }
    

    /*
        Logout user help function
    */
    func logoutUser(_ username:String, password:String){
        NSLog("server time out: \(username)")
        NSLog("server time out: \(password)")
        
        let urlString = kBaseURLString + "login.cgi"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let parameters = [
            "username" : username,
            "password" : password,
            "action"   : "logout"
        ]
        
        Alamofire.request(urlString, method: .post, parameters:parameters)
            .responseJSON(completionHandler: { response in
                switch(response.result){
                case .success(let JSON):
                    let data = JSON as! [String : AnyObject]
                    let session_token = data["session_token"] as! Int
                    
                    if session_token == 0 {
                        appDelegate.username = ""
                        appDelegate.session_token = ""
                    }
                    print(session_token)
                case .failure(let error):
                    print(error)
                    break
                }
            })
    }
    
    
    /*
        Display error returnned from server
    */
    func displayErrorMessageAlert(error : String) {
        let alertController = UIAlertController(title: "Error message", message: error, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}






