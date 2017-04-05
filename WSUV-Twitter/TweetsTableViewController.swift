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
 
    @IBOutlet weak var addTweetButton: UIBarButtonItem!
    var enableLogin = true
    var enableLogout = false
    var enableRegister = true
    
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

        //self.refreshTweets(self)
        
        
        if self.enableLogin == true {
            addTweetButton.isEnabled = false
            // delete user info from keycain upon logout
            SSKeychain.deletePassword(forService: kWazzuTwitterPassword, account: "username")
            SSKeychain.deletePassword(forService: kWazzuTwitterPassword, account: "password")
            SSKeychain.deletePassword(forService: kWazzuTwitterPassword, account: "session_token")
        }
        
        NotificationCenter.default.addObserver(
            forName: kAddTweetNotification,
            object: nil,
            queue: nil) { (note : Notification) -> Void in
                if !self.refreshControl!.isRefreshing {
                    self.refreshControl!.beginRefreshing()
                    self.refreshTweets(self)
                }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tweet = appDelegate.tweets[indexPath.row]
        
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
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let username = SSKeychain.password(forService: kWazzuTwitterPassword, account: "username") {
            return username == appDelegate.tweets[indexPath.row].username
        }
        return false
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // delete tweet only supported if user is logged in
        if editingStyle == .delete {
            let urlString = kBaseURLString + "/del-tweet.cgi"
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let parameters = [
                "username" : SSKeychain.password(forService: kWazzuTwitterPassword, account: "username") as String,
                "session_token" : SSKeychain.password(forService: kWazzuTwitterPassword, account: "session_token") as String,
                "tweet_id"   : appDelegate.tweets[indexPath.row].tweet_id
                ] as [String : Any]
            
            Alamofire.request(urlString, method: .post, parameters:parameters)
                .responseJSON(completionHandler: { response in
                    switch(response.result){
                    case .success(let JSON):
                        let data = JSON as! [String:AnyObject]
                        if data["isdeleted"] as! Int == 1{
                            appDelegate.tweets.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        
                    case .failure(_):
                        if let httpStatusCode = response.response?.statusCode {
                            //tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
                            switch(httpStatusCode) {
                            case 404:
                                self.displayErrorMessageAlert(error: "Not Found : no such user or no such tweet.")
                            case 500:
                                self.displayErrorMessageAlert(error: "Internal server error.")
                            case 401:
                                self.displayErrorMessageAlert(error: "Unauthorized.")
                            case 403:
                                self.displayErrorMessageAlert(error: "Forbidded : not the user's tweet.")
                            case 400:
                                self.displayErrorMessageAlert(error: "Bad Request : all parameters not provided.")
                            default:
                                self.displayErrorMessageAlert(error: "Error occured.")
                            }
                        }
                    }
                })
        }
        
    }
    
    
    /*
        Refresh action inplementation. refresh is trigered on pull down gesture
     */
    @IBAction func refreshTweets(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        let lastTweetDate = appDelegate.lastTweetDate()
        let dateStr = dateFormatter.string(from: lastTweetDate as Date)
        
        Alamofire.request(kBaseURLString + "/get-tweets.cgi", method: .get, parameters: ["date": dateStr]).responseJSON{ response in
            switch(response.result) {
            case .success(let JSON):
                let dict = JSON as! [String : AnyObject]
                let tweets = dict["tweets"] as! [[String : AnyObject]]
                
                for tweet in tweets {
                    let isdeleted = tweet["isdeleted"] as! Int
                    if isdeleted == 0 {

                    let date = dateFormatter.date(from: tweet["time_stamp"] as! String)
                        let t = Tweet(tweet_id:tweet["tweet_id"] as! Int, username:tweet["username"] as! String, isDeleted:isdeleted, tweet:tweet["tweet"] as! NSString, date:date!)
                        appDelegate.tweets.append(t)
                    }
                    else{
                        //XXX implent delete tweet
                        if !appDelegate.tweets.isEmpty{
                            let index = appDelegate.tweets.index(where: {$0.tweet_id == tweet["tweet_id"] as! Int})
                            if index != nil{
                                appDelegate.tweets.remove(at: index!)
                            }
                        }
                    }
                }
                appDelegate.tweets.sort(by: {$0.date > $1.date})
                self.tableView.reloadData() // force table-view to be updated
                self.refreshControl?.endRefreshing()
                
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
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    /*
        Manage account menu
    */
    @IBAction func manageAccount(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Manage Account", message: nil, preferredStyle: .actionSheet)
    
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Register user alert
        if self.enableRegister == true {
            alertController.addAction(UIAlertAction(title: "Register", style: .default, handler: { _ in
                
                let alertC = UIAlertController(title: "Register", message: "Please chose a username & paswword", preferredStyle: .alert)
                
                alertC.addTextField { (textField : UITextField) -> Void in
                    textField.placeholder = "Username"
                }
                alertC.addTextField { (textField : UITextField) -> Void in
                    textField.isSecureTextEntry = true
                    textField.placeholder = "Password"
                }
                
                alertC.addTextField { (textField : UITextField) -> Void in
                    textField.isSecureTextEntry = true
                    textField.placeholder = "Re-enter password"
                }
                
                alertC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                alertC.addAction(UIAlertAction(title: "Register", style: .default, handler: { _ in
                    let usernameTextField = alertC.textFields![0]
                    let passwordTextField = alertC.textFields![1]
                    let passwordTextField2 = alertC.textFields![2]
                    
                    // ... check for empty textfields
                    if let username = usernameTextField.text {
                        if let password = passwordTextField.text {
                            if let password2 = passwordTextField2.text {
                                if password == password2 {
                                    self.registerUser(username, password: password)
                                }
                                else{
                                    self.displayErrorMessageAlert(error: "The password you entered does not match !")
                                }
                            }
                        }
                    }
                }))
                
                self.present(alertC, animated: true, completion: nil)
            }))
        }
        
        // Login user alert
        if self.enableLogin == true {
            //if user previously logged in, relog in user
            if SSKeychain.password(forService: kWazzuTwitterPassword, account: "session_key") != nil {
                let username = SSKeychain.password(forService: kWazzuTwitterPassword, account: "username")
                let password = SSKeychain.password(forService: kWazzuTwitterPassword, account: "password")
                self.loginUser(username!, password: password!)
            }
            else{
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
            }
        }
        
        // Logout user alert
        if self.enableLogout == true {
            alertController.addAction(UIAlertAction(title: "Logout", style: .default, handler: { _ in
                let alertC = UIAlertController(title: "Logout", message: "You successfully logged out", preferredStyle: .alert)
                alertC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                let session_token = SSKeychain.password(forService: kWazzuTwitterPassword, account: "session_token")
                
                if session_token != nil {
                    let password = SSKeychain.password(forService: kWazzuTwitterPassword, account: "password")
                    let username = SSKeychain.password(forService: kWazzuTwitterPassword, account: "username")
                    
                    if self.logoutUser(username!, password: password!) == true{
                        self.present(alertC, animated: true, completion: nil)
                    }
                }
                else {
                    self.displayErrorMessageAlert(error: "There is no user loggin for this session !!")
                }
            }))
        }
        
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
        
        let urlString = kBaseURLString + "/register.cgi"
        let parameters = [
            "username" : username,
            "password" : password,
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler:  {response in
            switch(response.result) {
            case .success(let JSON):
                let dict = JSON as! [String : AnyObject]
                self.addTweetButton.isEnabled = true
                self.enableLogout = true
                self.enableRegister = false
                self.enableLogin = false
                self.title = username
                
                // save user info in the Keychain for it to be encrypted
                SSKeychain.setPassword(username, forService: kWazzuTwitterPassword, account: "username")
                SSKeychain.setPassword(password, forService: kWazzuTwitterPassword, account: "password")
                SSKeychain.setPassword(dict["session_token"] as! String, forService: kWazzuTwitterPassword, account: "session_token")

            case .failure( _):
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 404:
                        self.displayErrorMessageAlert(error: "Invalid request.")
                    case 500:
                        self.displayErrorMessageAlert(error: "Internal server error.")
                    case 409:
                        self.displayErrorMessageAlert(error: "Conflict, username already exists.")
                    case 400:
                        self.displayErrorMessageAlert(error: "Bad request, both username and password not provided.")
                    default:
                        self.displayErrorMessageAlert(error: "Error occured.")
                    }
                }
            }})
    }
    
    
    /*
        login helper function
    */
    func loginUser(_ username:String, password:String){

        let urlString = kBaseURLString + "/login.cgi"
        let parameters = [
            "username" : username,
            "password" : password,
            "action" : "login"
        ]
        
        Alamofire.request(urlString, method:.post, parameters:parameters)
            .responseJSON(completionHandler: { response in
                switch(response.result){
                case .success(let JSON):
                    let dict = JSON as! [String : AnyObject]
                    self.addTweetButton.isEnabled = true
                    self.enableLogout = true
                    self.enableRegister = false
                    self.enableLogin = false
                    self.title = username
                    
                    // save user info in the Keychain for it to be encrypted
                    SSKeychain.setPassword(username, forService: kWazzuTwitterPassword, account: "username")
                    SSKeychain.setPassword(password, forService: kWazzuTwitterPassword, account: "password")
                    SSKeychain.setPassword(dict["session_token"] as! String, forService: kWazzuTwitterPassword, account: "session_token")
                    
                case .failure( _):
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 404:
                            self.displayErrorMessageAlert(error: "Not found, No such user.")
                        case 401:
                            self.displayErrorMessageAlert(error: "Unauthorized.)")
                        case 500:
                            self.displayErrorMessageAlert(error: "Server error.)")
                        case 400:
                            self.displayErrorMessageAlert(error: "Bad request, both username and password not provided.)")
                        default:
                            self.displayErrorMessageAlert(error: "An error occured.")
                        }
                    }
                }
            })
    }
    

    /*
        Logout user helper function
    */
    func logoutUser(_ username:String, password:String) -> Bool {
        
        var flag = false
        let urlString = kBaseURLString + "/login.cgi"
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
                    let session_token = data["session_token"] as! String
                    
                    if session_token == "0" {
                        flag = true

                        // delete user info from keycain upon logout
                        SSKeychain.deletePassword(forService: kWazzuTwitterPassword, account: "username")
                        SSKeychain.deletePassword(forService: kWazzuTwitterPassword, account: "password")
                        SSKeychain.deletePassword(forService: kWazzuTwitterPassword, account: "session_token")
                        
                        self.enableLogin = true
                        self.enableRegister = true
                        self.enableLogout = false
                        self.addTweetButton.isEnabled = false
                        self.title = "Tweets"
                    }
                    print(session_token)
                case .failure( _):
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 404:
                            self.displayErrorMessageAlert(error: "Not found, No such user.")
                        case 401:
                            self.displayErrorMessageAlert(error: "Unauthorized.")
                        case 500:
                            self.displayErrorMessageAlert(error: "Server error.")
                        case 400:
                            self.displayErrorMessageAlert(error: "Bad request, both username and password not provided.")
                        default:
                            self.displayErrorMessageAlert(error: "Error occured.")
                        }
                    }
                }
            })
        return flag
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






