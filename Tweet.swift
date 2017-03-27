//
//  Tweet.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/23/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import Foundation
import Alamofire

let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"

class Tweet {
    var tweet_id : Int
    var username : String
    var isdeleted : Bool
    var tweet : String
    var date : NSDate
    
    init() {
        tweet_id = 0
        username = String()
        isdeleted = false
        tweet = String()
        date = NSDate()
    }
    
    func getTweets() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        var lastTweetDate : Date? = nil
        let dateStr = dateFormatter.string(from: lastTweetDate! as Date)
        
        Alamofire.request(kBaseURLString + "/get-tweets.cgi", method: .get, parameters: ["date":dateStr]).responseJSON{response in
            switch(response.result) {
                case .success(let JSON):
                    let dict = JSON as! [String : AnyObject]
                    let tweets = dict["tweets"] as! [[String : AnyObject]]
                    NSLog("\(tweets)")
                    //self.tableView.reloadData()
                    //self.refreshControl?.endrefreshing()
                    break
                case .failure (let error):
                    var message : String
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode){
                            case 500:
                                NSLog("server error");
                                break
                            case 404:
                                NSLog("request not found")
                                break
                            default: break
                        }
                    } else {
                        message = error.localizedDescription
                        NSLog("server time out: \(message)")
                    }
                //self.refreshControl?.endRefreshing()
            }
        }
    }

}
