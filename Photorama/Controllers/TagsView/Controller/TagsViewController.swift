//
//  TagsViewController.swift
//  Photorama
//
//  Created by Jason Ngo on 2018-07-26.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import CoreData
import UIKit

class TagsViewController: UITableViewController {
    var photoStore: PhotoStore!
    var photo: Photo!

    var selectedTagPaths = [IndexPath]()

    let tagDataSource = TagDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = tagDataSource
        tableView.delegate = self

        updateTags()
    }

    func updateTags() {
        photoStore.fetchAllTags { (result) in
            switch result {
            case let .success(tags):
                self.tagDataSource.tags = tags
                guard let photoTags = self.photo.tags as? Set<Tag> else {
                    return
                }

                for tag in photoTags {
                    if let index = self.tagDataSource.tags.index(of: tag) {
                        let indexPath = IndexPath(row: index, section: 0)
                        self.selectedTagPaths.append(indexPath)
                    }
                }
            case let .failure(error):
                print("Error fetching tags \(error)")
            }

            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }

    // MARK: - IBActions

    @IBAction func done(_: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func addTag(_: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .alert)

        alertController.addTextField {
            field in
            field.placeholder = "Tag name"
            field.autocapitalizationType = .words
        }

        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            if let tagName = alertController.textFields?.first?.text {
                let context = self.photoStore.persistentContainer.viewContext
                let newTag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context)

                newTag.setValue(tagName, forKey: "name")

                do {
                    try self.photoStore.persistentContainer.viewContext.save()
                } catch let error {
                    print("Error trying to save tags: \(error)")
                }

                self.updateTags()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tagDataSource.tags[indexPath.row]

        if let index = selectedTagPaths.index(of: indexPath) {
            selectedTagPaths.remove(at: index)
            photo.removeFromTags(tag)
        } else {
            selectedTagPaths.append(indexPath)
            photo.addToTags(tag)
        }

        do {
            try photoStore.persistentContainer.viewContext.save()
        } catch let err {
            print("Core data failed to save \(err)")
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedTagPaths.index(of: indexPath) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
} // TagsViewController
