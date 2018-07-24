//
//  Photo.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation

class Photo {
    
    let title:String
    let remoteURL: URL
    let photoID: String
    let dateTaken: Date
    
    init(title: String, remoteURL: URL, photoID: String, dateTaken: Date) {
        self.title = title
        self.remoteURL = remoteURL
        self.photoID = photoID
        self.dateTaken = dateTaken
    }

} // Photo

extension Photo: Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.photoID == rhs.photoID
    }
}
