//
//  TagsViewController.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-26.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import CoreData

class TagsViewController: UITableViewController {
    
    var photoStore: PhotoStore!
    var photo: Photo!
    
    var selectedTagPaths = [IndexPath]()
}
