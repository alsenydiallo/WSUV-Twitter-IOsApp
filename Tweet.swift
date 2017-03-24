//
//  Tweet.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/23/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import Foundation
import Alamofire

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
    
    func loadTweets(fromDate : NSDate) {
        
    }
    
}
