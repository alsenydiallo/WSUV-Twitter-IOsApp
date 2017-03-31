//
//  Tweet.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/23/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import Foundation
import Alamofire


class Tweet: NSObject, NSCoding {
    var tweet_id : Int
    var username : String
    var isDeleted : Int
    var tweet : NSString
    var date : Date
    
    var password : NSString? = nil
    var sessionKey : NSString? = nil
    
    /*override init() {
        tweet_id = 0
        username = String()
        isDeleted = false
        tweet = NSString()
        date = Date()
    }*/
    
    init (tweet_id:Int, username:String, isDeleted:Int, tweet:NSString, date:Date){
        self.tweet_id = tweet_id
        self.username = username
        self.isDeleted = isDeleted
        self.tweet = tweet
        self.date = date
    }
    
    static func == (tweet1:Tweet, tweet2:Tweet) -> Bool {
        return tweet1.tweet_id == tweet2.tweet_id
    }
    
    static func < (tweet1:Tweet, tweet2:Tweet) -> Bool {
        return tweet1.tweet_id < tweet2.tweet_id
    }
    
    required convenience init(coder aDecoder: NSCoder){
        let tweet_id = aDecoder.decodeInteger(forKey: "tweet_id")
        let username = aDecoder.decodeObject(forKey: "username") as! String
        let isDeleted = aDecoder.decodeInteger(forKey: "isDeleted")
        let tweet = aDecoder.decodeObject(forKey: "tweet") as! NSString
        let date = aDecoder.decodeObject(forKey: "date") as! Date
        
        self.init(
            tweet_id: tweet_id,
            username: username,
            isDeleted: isDeleted,
            tweet: tweet,
            date:date
        )
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(tweet_id, forKey: "tweet_id")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(isDeleted, forKey: "isDeleted")
        aCoder.encode(tweet, forKey: "tweet")
        aCoder.encode(date, forKey: "datae")
    }
    
}
