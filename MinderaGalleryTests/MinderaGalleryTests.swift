//
//  MinderaGalleryTests.swift
//  MinderaGalleryTests
//
//  Created by Quentin Beaudouin on 14/03/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import XCTest
@testable import MinderaGallery
@testable import AlamofireImage

class MinderaGalleryTests: XCTestCase {
    
    var controllerUnderTest: GalleryVC!
    
    override func setUp() {
        super.setUp()
        
        controllerUnderTest = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! GalleryVC!
    }
    
    override func tearDown() {
        
        controllerUnderTest = nil
        super.tearDown()
    }
    
    func testGalleryVCNoPhotosAfterInitIfCleared() {
        APIConnector.clearSavedPhotos()
        XCTAssertNil(controllerUnderTest.photos)
    }
    
    func testCallAPIPhotosDefaultTagPage1() {

        APIConnector.getSearchPhotos(page: 1) { (photos, error) in
            print(error?.localizedDescription ?? "no error")
            if error == nil {
                XCTAssertNotNil(photos)
            }
        }
        
    }
    
    func testPerformanceDeserialiseCachedJsonDefaultLimit() {

        let promise = expectation(description: "Photos fetched")
        
        APIConnector.getSearchPhotos(page: 1) { (photos, error) in
            if error != nil { print(error!.localizedDescription) }
            else { promise.fulfill() }
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        self.measure {
            _ = APIConnector.getSearchPhotosCached()
        }
        
    }
    
    func testPerformanceDeserialiseCachedJsonLimit1000() {
        
        let promise = expectation(description: "Photos fetched")
        
        APIConnector.getSearchPhotos(page: 1, limit: 1000) { (photos, error) in
            if error != nil { print(error!.localizedDescription) }
            else { promise.fulfill() }
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        self.measure {
            _ = APIConnector.getSearchPhotosCached()
        }
        
    }
    
    func testCacheMissingImage() {
        
        //XCTAssertEqual(photos, nil, "searchResults should be nil before call")

        APIConnector.getSearchPhotos(page: 1) { (photos, error) in
            print(error?.localizedDescription ?? "no error")
            guard let photos = photos else { return }
            let urlCache = UIImageView.af_sharedImageDownloader.sessionManager.session.configuration.urlCache
            for photo in photos {
                let request = URLRequest(url: photo.largeSquareUrl)
                // Clear the URLRequest from the on-disk cache
                urlCache?.removeCachedResponse(for: request)
            }
            
            APIConnector.cacheMissingImage(completion: {
                
                var responses = [CachedURLResponse]()
                for photo in photos {
                    let request = URLRequest(url: photo.largeSquareUrl)
                    guard let cached = urlCache?.cachedResponse(for: request) else { continue }
                    responses.append(cached)
                }
                XCTAssertEqual(photos.count, responses.count, "all photos are cached")
            })
        }
        
    }

}
