//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation

enum FlickerError: Error {
    case invalidJSONData
}

enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
}

struct FlickrAPI {
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static var interestingPhotosURL: URL {
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h, date_taken"])
    } // interestingPhotosURL
    
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        
        var queryItems = [URLQueryItem]()
        var components = URLComponents(string: baseURLString)!
        
        let baseParameters = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParameters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        } // for
        
        if let additionalParameters = parameters {
            for (key, value) in additionalParameters {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            } // for
        } // if
        
        components.queryItems = queryItems
        
        return components.url!
        
    } // flickrURL(method:parameters:)
    
    static func photos(fromJSON data: Data) -> PhotosResult {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let photos = jsonDictionary["photos"] as? [String:Any],
                let photosArray = photos["photo"] as? [[String:Any]]
            else {
                return .failure(FlickerError.invalidJSONData)
            } // guard
            
            var finalPhotos = [Photo]()
            
            for photoJSON in photosArray {
                if let photo = photo(fromJSON: photoJSON) {
                    finalPhotos.append(photo)
                } // if
            } // for
            
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                // there was an error parsing the JSON
                return .failure(FlickerError.invalidJSONData)
            } // if
            
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        } // do
        
    } // photos(data:) -> PhotosResult
    
    private static func photo(fromJSON json: [String: Any]) -> Photo? {
        
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString)
        else {
            return nil
        } // guard
        
        return Photo(title: title, remoteURL: url, photoID: photoID, dateTaken: dateTaken)
        
    } // photo(json:) -> Photo?
    
} // FlickrAPI

