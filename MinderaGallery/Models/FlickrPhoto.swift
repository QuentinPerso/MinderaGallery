//
//  FlickrPhoto.swift
//  MinderaGallery
//
//  Created by Quentin Beaudouin on 15/03/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation

class FlickrPhoto: NSObject, NSCoding {
    
    var uniqueId: String!
    var title:String?
    var largeSquareUrl = URL(string:"noLSUrl")!
    var largeUrl = URL(string:"noLUrl")!
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? FlickrPhoto {
            return self.uniqueId == object.uniqueId
        }
        else {
            return false
        }
    }
    
    init(dictionary:[String : AnyObject]) {

        self.uniqueId = dictionary["id"] as? String
        self.title = dictionary["title"] as? String
        if let urlString = dictionary["url_q"] as? String, let url = URL(string:urlString) {
            self.largeSquareUrl = url
        }
        if let urlString = dictionary["url_l"] as? String, let url = URL(string:urlString) {
            self.largeUrl = url
        }
        
        super.init()
        
        
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uniqueId, forKey: "uniqueId")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(largeSquareUrl, forKey: "largeSquareUrl")
        aCoder.encode(largeUrl, forKey: "largeUrl")
    }

    
    required init?(coder aDecoder: NSCoder) {
        self.uniqueId = aDecoder.decodeObject(forKey: "uniqueId") as? String
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        if let urlString = aDecoder.decodeObject(forKey: "largeSquareUrl") as? String, let url = URL(string:urlString) {
            self.largeSquareUrl = url
        }
        if let urlString = aDecoder.decodeObject(forKey: "largeUrl") as? String, let url = URL(string:urlString) {
            self.largeUrl = url
        }
        super.init()
    }
    
    
    
}


