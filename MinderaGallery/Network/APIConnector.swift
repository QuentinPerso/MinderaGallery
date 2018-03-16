//
//  APIConnector.swift
//  MinderaGallery
//
//  Created by Quentin Beaudouin on 15/03/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class APIConnector: NSObject{
    
    private static let apiBaseURL = "https://api.flickr.com/services/rest"
    private static let apiKey = "f9cc014fa76b098f9e82f1c288379ea1"
    private static let kCachedResponse = "quentin.minderaGallery.saveLastPhotos"
    
    
    /* COMMENT:
     * For such a small json I don't feel I need to create a background queue / closure so as to maintain code simplicity
     */
    
    static func getSearchPhotosCached() -> [FlickrPhoto]? {
        
        guard let savedPhotos = UserDefaults.standard.string(forKey: kCachedResponse) else {
            return nil
        }

        do{
            guard let jsonDict = try JSONSerialization.jsonObject(with: savedPhotos.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject] else {
                print("error deserializing jsonDict from userDefault")
                return nil
            }
            
            if let photoDict = jsonDict["photos"] as? [String: AnyObject],
                let photosDicts = photoDict["photo"] as? [[String: AnyObject]] {
                
                var photos = [FlickrPhoto]()
                for photoDict in photosDicts {
                    photos.append(FlickrPhoto(dictionary: photoDict))
                }
                return photos
            }
        }  
        catch {
            print("error deserializing jsonDict from userDefault")
            return nil
        }
        return nil
    }
    
    static func clearSavedPhotos() {
        
        UserDefaults.standard.removeObject(forKey: kCachedResponse)
        UserDefaults.standard.synchronize()
        
    }
    
    static func cacheMissingImage(completion:(()->())? = nil) {

        guard let photos = APIConnector.getSearchPhotosCached() else { return }
        
        for photo in photos {
            let urlRequest = URLRequest(url: photo.largeSquareUrl)
            UIImageView.af_sharedImageDownloader.download(urlRequest, completion: { (response) in
                if photo == photos.last { completion?() }   
            })
        }
    }

    static func getSearchPhotos(tags:[String]?=["kitten"], page:Int, limit:Int = 50, completion:@escaping ([FlickrPhoto]?, NSError?) -> Void){

        var queryParams = [
            "method" : "flickr.photos.search",
            "api_key": APIConnector.apiKey,
            "format" : "json",
            "nojsoncallback" : 1,
            "extras" : "url_q,url_l",
            "per_page" : limit,
            "page" : page
            ] as [String : Any]
        
        let tagsString = (tags == nil) ? nil:tags!.joined(separator: ",")
        if tagsString != nil { queryParams["tags"] = tagsString! }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(apiBaseURL, parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let jsonDict = response.result.value as? [String: AnyObject] else {
                let error = NSError(domain: "quentin.minderaGallery",
                                    code: ErrorCode.apiJsonBadFormat.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: "Error deserializing json : \(response.result.value ?? "no response value")"])
                completion(nil, error)
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
                completion(photos, nil)
            }
            else if let error = jsonDict["error"]{
                let error = NSError(domain: "quentin.minderaGallery",
                                    code: ErrorCode.apiError.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: "\(error)"])
                completion(nil, error)
            }
            else {
                let error = NSError(domain: "quentin.minderaGallery",
                                    code: ErrorCode.apiJsonBadFormat.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: "jsonDict[\"photo\"] not found"])
                completion(nil, error)
            }

        }
    }
    
    
}















