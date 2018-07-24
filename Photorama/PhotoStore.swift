//
//  PhotoStore.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum ImageError: Error {
    case imageCreationError
}

class PhotoStore {
    
    let imageStore = ImageStore()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchInterestingPhotos(completionHandler: @escaping (PhotosResult) -> Void) {
        
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            // Bronze Challenge: Print status code and all header fields
//            let httpResponse = response as! HTTPURLResponse
//            print("Status code: \(httpResponse.statusCode)")
//
//            for (key, value) in httpResponse.allHeaderFields.enumerated() {
//                print("Field: \(key) Value: \(value)")
//            }
            
            let result = self.processPhotosRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completionHandler(result)
            }
        } // task
        
        task.resume()
        
    } // fetchInterestingPhotos
    
    // Silver Challenge: Use the Flickr API's getRecent photos 
    func fetchRecentPhotos(completetionHandler: @escaping (PhotosResult) -> Void) {
        
        let url = FlickrAPI.recentPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            let result = self.processPhotosRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completetionHandler(result)
            }
        } // task
        
        task.resume()

    } // fetchRecentPhotos
    
    func fetchImage(for photo: Photo, completionHandler: @escaping (ImageResult) -> Void) {
        
        let photoKey = photo.photoID
        if let image = self.imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completionHandler(.success(image))
            }
            
            return
        }
        
        let url = photo.remoteURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
            
            OperationQueue.main.addOperation {
                completionHandler(result)
            }
        }
        
        task.resume()
        
    } // fetchImage(photo:completionHandler:)
    
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrAPI.photos(fromJSON: jsonData)
    } // processPhotosRequest(data:error:)
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        guard let imageData = data, let image = UIImage(data: imageData) else {
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(ImageError.imageCreationError)
            } // if
        } // guard
        
        return .success(image)
        
    } // processImageRequest(data:error:) -> ImageResult
    
} // PhotoStore

