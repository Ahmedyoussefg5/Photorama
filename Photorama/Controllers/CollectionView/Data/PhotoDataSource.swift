//
//  PhotoDataSource.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

/// PhotoDataSource represents the data source used to provide data
/// for the collection view handled by PhotosViewController

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    var photos = [Photo]()

    // MARK: - UICollectionViewDataSource

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell

        let photo = photos[indexPath.row]
        cell.photoDescription = photo.title

        return cell
    }
    
} // PhotoDataSource
