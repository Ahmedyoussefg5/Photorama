//
//  PhotoStore.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import CoreData
import UIKit

// enum associated with fetching photos
enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

// enum associated with fetching images
enum ImagesResult {
    case success(UIImage)
    case failure(Error)
}

// enum associated with fetching tags
enum TagsResult {
    case success([Tag])
    case failure(Error)
}

enum ImageError: Error {
    case imageCreationError
}

// PhotoStore manages the ImageStore and handles making the calls to the FlickrAPI
class PhotoStore {
    
    let imageStore = ImageStore()

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let err = error {
                print("Error setting up Core Data with error: \(err)")
            }
        })
        return container
    }()
    
    /// Use URLSession Factory to create requests
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // MARK: - Fetching Functions

    func fetchInterestingPhotos(completionHandler: @escaping (PhotosResult) -> Void) {
        guard let url = FlickrAPI.interestingPhotosURL else { return }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in

            // Bronze Challenge: Print status code and all header fields
            let httpResponse = response as! HTTPURLResponse
            print("Status code: \(httpResponse.statusCode)")

            for (key, value) in httpResponse.allHeaderFields.enumerated() {
                print("Field: \(key) Value: \(value)")
            }

            self.processPhotosRequest(data: data, error: error, completionHandler: { (result) in
                OperationQueue.main.addOperation {
                    completionHandler(result)
                }
            })
        }

        task.resume()
    }

    // Silver Challenge: Use the Flickr API's getRecent photos
    func fetchRecentPhotos(completetionHandler: @escaping (PhotosResult) -> Void) {
        guard let url = FlickrAPI.recentPhotosURL else { return }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in

            let httpResponse = response as! HTTPURLResponse
            print("Status code: \(httpResponse.statusCode)")
            
            for (key, value) in httpResponse.allHeaderFields.enumerated() {
                print("Field: \(key) Value: \(value)")
            }

            self.processPhotosRequest(data: data, error: error, completionHandler: { (result) in
                OperationQueue.main.addOperation {
                    completetionHandler(result)
                }
            })
        }

        task.resume()
    }

    func fetchImage(for photo: Photo, completionHandler: @escaping (ImagesResult) -> Void) {
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photo ID")
        }

        // Image already exists in the ImageStore so return image
        // instead of making another fetching call
        if let image = self.imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completionHandler(.success(image))
            }

            return
        }

        guard let url = photo.remoteURL else {
            preconditionFailure("Photo expected to have a remote URL")
        }

        let request = URLRequest(url: url as URL)
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = self.processImageRequest(data: data, error: error)

            let httpResponse = response as! HTTPURLResponse
            print("Status code: \(httpResponse.statusCode)")
            
            for (key, value) in httpResponse.allHeaderFields.enumerated() {
                print("Field: \(key) Value: \(value)")
            }
            
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }

            OperationQueue.main.addOperation {
                completionHandler(result)
            }
        }

        task.resume()
    } // fetchImage(photo:completionHandler:)
    
    // Fetches photos saved in the containers viewcontext
    func fetchAllPhotos(completionHandler: @escaping (PhotosResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]

        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completionHandler(.success(allPhotos))
            } catch let err {
                completionHandler(.failure(err))
            }
        }
    }

    func fetchAllTags(completionHandler: @escaping (TagsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]

        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try viewContext.fetch(fetchRequest)
                completionHandler(.success(allTags))
            } catch let err {
                completionHandler(.failure(err))
            }
        }
    }
    
    // MARK: - Helper Functions

    private func processPhotosRequest(data: Data?, error: Error?, completionHandler: @escaping (PhotosResult) -> Void) {
        guard let jsonData = data else {
            completionHandler(.failure(error!))
            return
        }

        persistentContainer.performBackgroundTask { (context) in
            let result = FlickrAPI.photos(fromJSON: jsonData, into: context)

            do {
                try context.save()
            } catch {
                print("Error saving to Core Data: \(error)")
                completionHandler(.failure(error))
                return
            }

            switch result {
            case let .success(photos):
                let photosID = photos.map { return $0.objectID }
                let viewContext = self.persistentContainer.viewContext
                let viewContextPhotos = photosID.map { return viewContext.object(with: $0) } as! [Photo]
                completionHandler(.success(viewContextPhotos))
            case .failure:
                completionHandler(result)
            }
        }
    }

    private func processImageRequest(data: Data?, error: Error?) -> ImagesResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
            // Couldn't create an image
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(ImageError.imageCreationError)
            }
        }

        return .success(image)
    }
    
} // PhotoStore
