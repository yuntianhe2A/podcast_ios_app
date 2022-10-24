//
//  DatabaseProtocol.swift
//  FinalAssignment
//
//  Created by Yansong Li on 22/5/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//

import Foundation
import UIKit
enum DatabaseChange {
case add
case remove
case update }
enum ListenerType {
case team
case heroes
case all
}
//enum ListenerType {
//    case podcast
//
//}

protocol DatabaseListener: AnyObject {
 // var listenerType: ListenerType {get set}
  func onSavingChange(change: DatabaseChange, savingPodcast: [Podcast])
  //func onHeroListChange(change: DatabaseChange, heroes: [SuperHero])
}

//protocol coredataProtocol:AnyObject {
//    func addEpisodeToPlaylist(episode:Episode,playlist:Playlist)
//    func newEpisodeDownloaded()
//}
protocol DatabaseProtocol: AnyObject {
//var defaultTeam: Team {get}
func cleanup()
func addPodcast(podcastToBeSaved:Podcast) -> Podcast
func deletePodcast(podcastToBeDeleted:Podcast)
//func addTeam(teamName: String) -> Team
//func addHeroToTeam(hero: SuperHero, team: Team) -> Bool
//func deleteSuperHero(hero: SuperHero)
//func deleteTeam(team: Team)
//func removeHeroFromTeam(hero: SuperHero, team: Team)
func addListener(listener: DatabaseListener)
func removeListener(listener: DatabaseListener)
//func uploadImage(podcast:Podcast)
//
//func FetchFirebasePodcastImage(podcastId:String)->UIImage
}
