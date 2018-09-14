//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import CoreData
import Foundation

enum FlickerError: Error {
    case invalidJSONData
}

/// Represents Flickr endpoints our API is able to handle
enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
    case recentPhotos = "flickr.photos.getRecent"
}

struct FlickrAPI {
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static var interestingPhotosURL: URL? {
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h, date_taken"])
    }

    static var recentPhotosURL: URL? {
        return flickrURL(method: .recentPhotos, parameters: ["extras": "url_h, date_taken"])
    }
    
    static func photos(fromJSON data: Data, into context: NSManagedObjectContext) -> PhotosResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let photos = jsonDictionary["photos"] as? [String: Any],
                let photosArray = photos["photo"] as? [[String: Any]] else {
                // JSON structure did not match
                return .failure(FlickerError.invalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            
            for photoJSON in photosArray {
                if let photo = photo(fromJSON: photoJSON, into: context) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                // Unable to parse any of the photos
                return .failure(FlickerError.invalidJSONData)
            }
            
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
    }
    
    // MARK: Helper Functions

    /// Builds the Flickr URL using the specified method and parameters
    /// If unable to build the url return nil
    private static func flickrURL(method: Method, parameters: [String: String]?) -> URL? {
        var queryItems = [URLQueryItem]()
        
        // Build the basic Flickr URL
        var components = URLComponents(string: baseURLString)!

        let baseParameters = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey,
        ]

        for (key, value) in baseParameters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        // Append additional query items
        if let additionalParameters = parameters {
            for (key, value) in additionalParameters {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }

        components.queryItems = queryItems
        
        return components.url
    }

    // Attempt to fetch/create a Photo object from the JSON data
    private static func photo(fromJSON json: [String: Any], into context: NSManagedObjectContext) -> Photo? {
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString)
        else {
            return nil
        }
        
        // Attempt to fetch the photo from persistent container
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.photoID)) == \(photoID)")
        fetchRequest.predicate = predicate

        var fetchPhotos: [Photo]?
        context.performAndWait {
            fetchPhotos = try? fetchRequest.execute()
        }
        
        // if successfully fetched image return the photo
        if let existingPhoto = fetchPhotos?.first {
            return existingPhoto
        }
        
        // Photo didn't already exist in context. Save photo into context
        var photo: Photo!
        context.performAndWait {
            photo = Photo(context: context)
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url as NSURL
            photo.dateTaken = dateTaken as NSDate
        }

        return photo
    }
    
} // FlickrAPI
