//
//  EpisodesOfPodcastTableViewController.swift
//  FinalAssignment
//
//  Created by user169705 on 6/2/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//

import UIKit

class EpisodesOfPodcastTableViewController: UITableViewController, EpisodeParserDelegate {
    var podcast:Podcast?
  
    var audioUrl=""
    var feedUrl=""
    
    func onFinishedParse(episodes: [Episode]) {
        episodeList=episodes
        DispatchQueue.main.async {
 self.tableView.reloadData()
 }    }
    
    var episodeList:[Episode]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let podcast=podcast{
            feedUrl=podcast.feedUrl!
           }
        let xmlParser = EpisodeXMLDecoder()
        xmlParser.parseEpisodeXMLWithURL(url: feedUrl, listener: self)

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return episodeList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeTableViewCell
        let currentEpisode=episodeList[indexPath.row]
       
  
        cell.urlLabel.text=currentEpisode.episodeTitle
        cell.descriptionLabel.text=currentEpisode.duration
        //cell.durationLabel.text=currentEpisode.duration
        
        // Configure the cell...

        return cell
    }
    
    
    
    //download Episode Audio file to local
    
    
    
   

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="playAudioSegue"{
               let cell=sender as! EpisodeTableViewCell
               let indexPath=tableView.indexPath(for: cell)
               let controller=segue.destination as! AudioViewController
            //enclosure!.url!
           
            controller.indexOfEpisode=indexPath!.row
            controller.episodeList=episodeList
            controller.podcastName=podcast!.podcastName!
        }
    }
    

}
