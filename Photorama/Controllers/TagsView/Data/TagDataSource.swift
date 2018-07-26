//
//  TagDataSource.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-26.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class TagDataSource: NSObject, UITableViewDataSource {
    
    var tags = [Tag]()
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag.name
        
        return cell
    }
    
}
