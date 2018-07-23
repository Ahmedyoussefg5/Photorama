//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-23.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var photoStore: PhotoStore!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        photoStore.fetchInterestingPhotos {
            (photosResult) in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos")
                
                if let firstPhoto = photos.first {
                    self.updateImageView(for: firstPhoto)
                }
                
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
            } // switch
        }
        
    } // viewDidLoad()
    
    func updateImageView(for photo: Photo) {
        photoStore.fetchImage(for: photo) {
            (imageResult) in
            
            switch imageResult {
            case let .success(image):
                print("Successfully created image")
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching photo image: \(error)")
            } // switch
        }
    }
    
} // PhotosViewController

