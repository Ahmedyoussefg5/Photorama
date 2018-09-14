//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

/// PhotosViewController handles the view presented on the homescreen
/// which fetches and displays photos in a grid like fasion

class PhotosViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!

    var photoStore: PhotoStore!
    let photoDataSource = PhotoDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = photoDataSource

        updateDataSource()
        
        photoStore.fetchInterestingPhotos { [weak self] (_) in
            self?.updateDataSource()
        }
    } // viewDidLoad()

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        switch segue.identifier {
        case "showPhotos"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]

                let destinationVC = segue.destination as! PhotoDetailViewController
                destinationVC.photo = photo
                destinationVC.photoStore = photoStore
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }

    private func updateDataSource() {
        photoStore.fetchAllPhotos { (result) in
            switch result {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }

            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
} // PhotosViewController

// MARK: - UICollectionViewDelegate
extension PhotosViewController: UICollectionViewDelegate {
    
    /// willDisplay makes for a good time to fetch image data
    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        
        // Download the image data
        photoStore.fetchImage(for: photo) { (imageResult) in
            guard case let .success(image) = imageResult else { return }
            
            // index path may change from when the fetching call was made. Make sure we use the right index path
            guard let photoIndex = self.photoDataSource.photos.index(of: photo) else { return }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // only update cell if it's still visible
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
    
}

