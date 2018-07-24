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
        
        photoStore.fetchInterestingPhotos {
            (photosResult) in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos")
                
//                if let firstPhoto = photos.first {
//                    self.updateImageView(for: firstPhoto)
//                }
                
                self.photoDataSource.photos = photos
                
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
                self.photoDataSource.photos.removeAll()
            } // switch
            
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
        
    } // viewDidLoad()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
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

