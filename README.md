Photorama
Flickr photo fetcher

Application created using the resource: iOS Programming: The Big Nerd Ranch Guide (6th Edition)

Practise Application that presents a grid view of photos fetched using the Flickr API. Users tap on photos to bring a more detailed view
of the photo. The detailed view allows users to add tags to specific photos. Photo data is saved to Core Data to provide persistent data
storage.

Application was created to practise concepts using:
- UIKit (UICollectionView, UITableView, UINavigationController)

Networking:
- URLSession
- URLSessionDataTask
- URLRequest

Storage:
- NSCache
- Core Data

Patterns:
- Dependency Injection
- Delegation/Data Source
- MVC

- Extensions used while conforming to protocols to provide better code readability.
- Certain calls are called asynchronously to improve user expereience and leave main queue free for UI 
