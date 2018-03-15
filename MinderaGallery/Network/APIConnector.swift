//
//  APIConnector.swift
//  MinderaGallery
//
//  Created by Quentin Beaudouin on 15/03/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit
import Alamofire

class APIConnector: NSObject{
    
    private static let apiBaseURL = "https://api.flickr.com/services/rest"
    private static let apiKey = "f9cc014fa76b098f9e82f1c288379ea1"
    private static let kCachedResponse = "quentin.minderaGallery.saveLastPhotos"
    
    static func getSearchPhotosCached(completion:@escaping ([FlickrPhoto]?) -> Void) {
        
        guard let savedPhotos = UserDefaults.standard.string(forKey: kCachedResponse) else {
            completion(nil)
            return
        }

        do{
            guard let jsonDict = try JSONSerialization.jsonObject(with: savedPhotos.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject] else {
                print("error deserializing jsonDict from userDefault")
                completion(nil)
                return
            }
            
            if let photoDict = jsonDict["photos"] as? [String: AnyObject],
                let photosDicts = photoDict["photo"] as? [[String: AnyObject]] {
                
                var photos = [FlickrPhoto]()
                for photoDict in photosDicts {
                    photos.append(FlickrPhoto(dictionary: photoDict))
                }
                completion(photos)
            }
        }  
        catch {
            completion(nil)
        }
        
        
    }

    static func getSearchPhotos(tags:[String]?=["kitten"], page:Int, completion:@escaping ([FlickrPhoto]?) -> Void){

        var queryParams = [
            "method" : "flickr.photos.search",
            "api_key": APIConnector.apiKey,
            "format" : "json",
            "nojsoncallback" : 1,
            "extras" : "url_q,url_l",
            "per_page" : 50,
            "page" : page
            ] as [String : Any]
        
        let tagsString = (tags == nil) ? nil:tags!.joined(separator: ",")
        if tagsString != nil { queryParams["tags"] = tagsString! }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(apiBaseURL, parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let jsonDict = response.result.value as? [String: AnyObject] else {
                print("error deserializing json", response.result.value ?? "no response value")
                completion(nil)
                return
            }
            
            //save jsonEncode
            let jsonString = String(data: response.data!, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: kCachedResponse)
            
            if let photoDict = jsonDict["photos"] as? [String: AnyObject],
                let photosDicts = photoDict["photo"] as? [[String: AnyObject]] {

                var photos = [FlickrPhoto]()
                for photoDict in photosDicts {
                    photos.append(FlickrPhoto(dictionary: photoDict))
                }
                completion(photos)
            }
            else if let error = jsonDict["error"]{
                print(error)
                completion(nil)
            }
            else {
                print("no error and no jsonDict[\"photo\"]?")
                completion(nil)
            }

        }
    }
    
    
}















