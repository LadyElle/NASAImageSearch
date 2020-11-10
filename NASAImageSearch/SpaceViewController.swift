//
//  ViewController.swift
//  MichelleStaffordCodingChallenge
//
//  Created by Michelle Stafford on 2019-03-31.
//  Copyright © 2019 Michelle Stafford. All rights reserved.
//

import Foundation
import UIKit


class SpaceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var spaceSearchResults = [Space]()
    var spaceSearchResultsTotalCount = 0
    private weak var delegate: SpaceViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search NASA's images of Space..."
        navigationItem.searchController = search
        
        tableView.prefetchDataSource = self
    }
    
    let search = UISearchController(searchResultsController: nil)
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return search.searchBar.text?.isEmpty ?? true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchBarIsEmpty() { return }
        
        var searchText = searchController.searchBar.text
        
        if (searchText?.contains(" "))!{
            searchText = searchText?.replacingOccurrences(of: " ", with: "+")
        }
        
        let searchURL  = URL(string: "https://images-api.nasa.gov/search?q="+searchText!+"&media_type=image")!
        
        self.populateSpaceSearchResults(searchURL: searchURL)
        
        tableView.reloadData()
    }
    
    var nextPage: String = ""
    var currentPage = 0
    
    var isFetchInProgress = false
    
    func populateSpaceSearchResults(searchURL: URL) {
        guard !isFetchInProgress else { return }
        
        isFetchInProgress = true
        
        let task = URLSession.shared.dataTask(with: searchURL) {(data, response, error) in
            guard let dataFromNASA: Data = data else {return}
            let json = try? JSON(data: dataFromNASA)
            
            let searchResults = json?["collection"]["items"]
            
            if self.currentPage < 101{
                self.currentPage += 1
                self.nextPage = (json?["collection"]["links"][0]["href"].stringValue)!
            }
            
            for (index, searchResult) in searchResults!{
                self.spaceSearchResultsTotalCount += 1
                let hrefString = searchResult["links"][0]["href"]
                if (!hrefString.stringValue.isEmpty){
                    let pictureURL = URL(string: hrefString.stringValue)
                    let pictureData = try? Data(contentsOf: pictureURL!)
                    if let imageData = pictureData{
                        let spacePicture = UIImage(data: imageData)
                        let spaceItemWithData = searchResult["data"][0]
                        let spaceAsset = Space(title: (spaceItemWithData["title"].stringValue), image: spacePicture!, description: spaceItemWithData["description"].stringValue, dateCreated: spaceItemWithData["date_created"].stringValue)
                        self.spaceSearchResults.append(spaceAsset)
                    }
                }
            }
            if !self.nextPage.isEmpty{
                let indexPathsToReload = self.calculateIndexPathsToReload(from: [self.spaceSearchResults.last!])
                self.delegate?.onFetchCompleted(with: indexPathsToReload)
            }
        }
        isFetchInProgress = false
        task.resume()
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            indicatorView.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    private func calculateIndexPathsToReload(from newSpaceSearchResults: [Space]) -> [IndexPath] {
        let startIndex = spaceSearchResults.count - newSpaceSearchResults.count
        let endIndex = startIndex + newSpaceSearchResults.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    
    func isActive() -> Bool {
        return search.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spaceSearchResultsTotalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCell", for: indexPath) as! SpaceCell
        
        if isLoadingCell(for: indexPath){
            cell.setSpacePreviewDetails(with: .none)
        }
        else{
            let space = spaceSearchResults[indexPath.row]
            cell.setSpacePreviewDetails(with: space)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpaceDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let space: Space
                space = spaceSearchResults[indexPath.row]
                
                let controller = (segue.destination as! SpaceDetailsViewController)
                controller.spaceDetail = space
            }
        }
    }
}

extension SpaceViewController: UITableViewDataSourcePrefetching, SpaceViewControllerDelegate {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            if !nextPage.isEmpty{
                populateSpaceSearchResults(searchURL: URL(string: nextPage)!)
            }
        }
    }
}

private extension SpaceViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= spaceSearchResults.count
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

protocol SpaceViewControllerDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
}
