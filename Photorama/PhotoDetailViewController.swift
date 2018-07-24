//
//  PhotoDetailViewController.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-24.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var photoStore: PhotoStore!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoStore.fetchImage(for: photo) { (result) in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
    
}
