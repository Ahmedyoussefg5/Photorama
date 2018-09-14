//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-24.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!

    var photoDescription: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // start spinner
        update(with: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // start spinner
        update(with: nil)
    }

    func update(with image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }

    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {
            super.isAccessibilityElement = newValue
        }
    }

    override var accessibilityLabel: String? {
        get {
            return photoDescription
        }
        set {
            // ignore attempts to set
        }
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return super.accessibilityTraits | UIAccessibilityTraitImage
        }
        set {
            // ignore attempts to set
        }
    }
    
} // PhotoCollectionViewCell
