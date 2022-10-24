//
//  FindAndSearchShowTableViewController.swift
//  FinalAssignment
//
//  Created by Yansong Li on 20/5/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//

import UIKit
import Firebase

class FindAndSearchShowTableViewController: UITableViewController,UISearchBarDelegate,URLSessionDelegate,URLSessionDownloadDelegate {
    
    
    let CELL_PODCAST = "ShowCell"
    var SearchPodcastsData:[Podcast]=[]
    var searchName:String = ""
    var indicator = UIActivityIndicatorView()
    
    weak var databaseController: DatabaseProtocol?
    var hasAddedPodcastIdentifier=0
    var poscastID=""
    //image download
    let config = URLSessionConfiguration.default
    lazy var session = {
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }()
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find new podcast"
        navigationItem.searchController = searchController
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
        
        
        
    }
    
    // MARK: - Search Bar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // If there is no text end immediately
        guard let searchText = searchBar.text, searchText.count > 0 else {
            return; }
        
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        SearchPodcastsData.removeAll()
        tableView.reloadData()
        searchName=searchText
        requestPodcast()
    }
    
    func requestPodcast() {
        
        let REQUEST_STRING = "https://itunes.apple.com/search?term=\(searchName)&entity=podcast"
        let url = URL(string: REQUEST_STRING)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true }
            if let error = error {
                print("Downlaod error: \(error)")
                return
            }
            
            let decoder = JSONDecoder()
            if let podcasts = try? decoder.decode(PodcastList.self, from: data!) {
                
                self.SearchPodcastsData=podcasts.podcasts
                DispatchQueue.main.async {
                    self.navigationItem.title = self.SearchPodcastsData[0].podcastName
                    self.tableView.reloadData()
                }
            }
        }
        task.resume() }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchPodcastsData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_PODCAST, for: indexPath) as! PodcastTableViewCell
        let podcast=SearchPodcastsData[indexPath.row]
        cell.podcastNameLabel.text=podcast.podcastName
        cell.podcastArtistLabel.text=podcast.artist
        print(podcast.podcastCoverImg)
        if let imageUrls = podcast.podcastCoverImg {
            if let image = podcast.image {
                // Use the image if already retreived.
                cell.cellImgView.image = image
            }
            else if podcast.imgDownloadIdentifier == nil {
                // Otherwise, request image.
                SearchPodcastsData[indexPath.row].imgDownloadIdentifier = downloadPodcastImage(imageURLString: podcast.podcastCoverImg!)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newPodcast=SearchPodcastsData[indexPath.row]
        databaseController!.addPodcast(podcastToBeSaved:newPodcast)
        
        //databaseController!.uploadImage(podcast:newPodcast)
        self.navigationController?.popViewController(animated: true)
        
    }
    //    override func viewWillDisappear(_ animated: Bool) {
    //        if hasAddedPodcastIdentifier==1{
    //
    //        }
    //    }
    
    
    
    func downloadPodcastImage(imageURLString: String) -> Int? {
        if let imageURL = URL(string: imageURLString) {
            let task = session.downloadTask(with: imageURL)
            task.resume()
            
            return task.taskIdentifier
        }
        return nil
    }
    
    // MARK: URL Session Task Delegate methods
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            print("Progress \(downloadTask.currentRequest!.description): \(progress)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        do {
            let data = try Data(contentsOf: location)
            
            // Find the index of the cell/episode that this download coresponds to.
            var cellIndex = -1
            for index in 0..<SearchPodcastsData.count {
                let podcast = SearchPodcastsData[index]
                if podcast.imgDownloadIdentifier == downloadTask.taskIdentifier {
                    SearchPodcastsData[index].image = UIImage(data: data)
                    cellIndex = index
                }
            }
            
            // If found the episode/cell to update, reload that row of tableview.
            if cellIndex >= 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: cellIndex, section: 0)], with: .automatic)
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
