//
//  Tweets.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/23/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import Foundation

class Tweets {
    var tweet_id : Int
    var username : NSString?
    var isdeleted : Bool
    var tweet : NSString?
    var date : NSDate?
    
    init() {
        tweet_id = 0
        username = NSString()
        isdeleted = false
        tweet = NSString()
        date = NSDate()
    }
    
}
