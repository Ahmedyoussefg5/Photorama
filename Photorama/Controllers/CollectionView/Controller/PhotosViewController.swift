//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var photoStore: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()
        
        photoStore.fetchInterestingPhotos {
            (photosResult) in
            
            self.updateDataSource()
        }
        
    } // viewDidLoad()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        photoStore.fetchImage(for: photo) {
            (imageResult) in
            
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
            case let .success(image) = imageResult else {
                return
            }
            
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
        
    }
    
//    func updateImageView(for photo: Photo) {
//        photoStore.fetchImage(for: photo) {
//            (imageResult) in
//
//            switch imageResult {
//            case let .success(image):
//                print("Successfully created image")
//                self.imageView.image = image
//            case let .failure(error):
//                print("Error fetching photo image: \(error)")
//            } // switch
//        }
//    }
    
} // PhotosViewController

