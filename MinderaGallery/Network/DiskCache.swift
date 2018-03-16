//
//  DiskCache.swift
//  MinderaGallery
//
//  Created by Quentin Beaudouin on 16/03/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation

class DiskCache: URLCache {
    
    private let constSecondsToKeepOnDisk = 30*24*60*60 // 30 days
    
    override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        
        var customCachedResponse = cachedResponse

        if let response = cachedResponse.response as? HTTPURLResponse,
            let contentType = response.allHeaderFields["Content-Type"] as? String,
            var newHeaders = response.allHeaderFields as? [String: String], contentType.contains("image") {
            newHeaders["Cache-Control"] = "public, max-age=\(constSecondsToKeepOnDisk)"
            if let url = response.url,
                let newResponse = HTTPURLResponse(url: url, statusCode: response.statusCode, httpVersion: "HTTP/1.1", headerFields: newHeaders) {
                customCachedResponse = CachedURLResponse(response: newResponse, data: cachedResponse.data, userInfo: cachedResponse.userInfo, storagePolicy: cachedResponse.storagePolicy)
            }
        }
        super.storeCachedResponse(customCachedResponse, for: request)
    }
    
}
