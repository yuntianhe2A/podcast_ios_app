//
//  MyFavouriteShowTableViewController.swift
//  FinalAssignment
//
//  Created by Yansong Li on 20/5/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//

import UIKit
import Firebase
//FindAndSearchShowSegue
import FirebaseStorage
class MyFavouriteShowTableViewController: UITableViewController,DatabaseListener {
  
    
    
    
    //var listenerType: ListenerType = .podcast
    
    func onSavingChange(change: DatabaseChange, savingPodcast: [Podcast]) {
        myFavPodcasts = savingPodcast
        tableView.reloadData()
    }
    
    var favouritePodcastRef: CollectionReference?
    var myFavPodcasts:[Podcast]=[]
    let SECTION_LOGIN=0
    let SECTION_PODCAST=1
    let CELL_LOGIN="loginCell"
    let CELL_PODCAST="ShowCell"
    var snapshotListener: ListenerRegistration?
    
    var database: Firestore?
      var storageReference = Storage.storage()
       
       var imageId=""
    weak var databaseController: DatabaseProtocol?
    lazy var authController={
        return Auth.auth()
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         //database = Firestore.firestore()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        return myFavPodcasts.count
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databaseController!.deletePodcast(podcastToBeDeleted: myFavPodcasts[indexPath.row])
                   
               }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let podcastCell = tableView.dequeueReusableCell(withIdentifier: CELL_PODCAST, for: indexPath) as! PodcastTableViewCell
        let podcast=myFavPodcasts[indexPath.row]
        
        podcastCell.podcastNameLabel.text=podcast.podcastName
        podcastCell.podcastArtistLabel.text=podcast.artist
        podcastCell.cellImgView.image=podcast.image
        podcastCell.descriptionLabel.text=podcast.releaseDate
        print(podcast.podcastId)
//        if let podcastID=podcast.podcastId{
//            let podcastImage=databaseController?.FetchFirebasePodcastImage(podcastId:podcastID)
//            podcastCell.cellImgView.image=podcastImage
//        }
        return podcastCell
    }
    
    func addPodcast(newPodcast: Podcast) {
        databaseController!.addPodcast(podcastToBeSaved:newPodcast)
    }
//    func deletePodcast(podcastToBeDeleted: Podcast) {
//        print(podcastToBeDeleted.podcastId)
//        databaseController!.deletePodcast(podcastToBeDeleted: podcastToBeDeleted)
//    }
//
    
        
       
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="showEpisodeListSegue"{
            let cell=sender as! PodcastTableViewCell
            let indexPath=tableView.indexPath(for: cell)
            let controller=segue.destination as! EpisodesOfPodcastTableViewController
            controller.feedUrl=myFavPodcasts[indexPath!.row].feedUrl!
            controller.podcast=myFavPodcasts[indexPath!.row]
            
        }
    }
    
    
}
