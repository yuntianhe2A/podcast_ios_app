//
//  Podcast.swift
//  FinalAssignment
//
//  Created by Yansong Li on 21/5/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//
import UIKit

struct PodcastList:Codable{
    var podcasts:[Podcast]
    private enum CodingKeys:String, CodingKey{
        case podcasts="results"
    }
}


class Podcast: Codable,Equatable{
    static func == (lhs: Podcast, rhs: Podcast) -> Bool {
        return true
    }
    
    
    var podcastId:String?
    var podcastName:String?
    var artist:String?
    var type:String?
    var price:Int=0
    var feedUrl:String?
    var podcastCoverImg:String?
    var imgDownloadIdentifier:Int?
    var image: UIImage?
    var imageDownloadUrl:String?
    var releaseDate:String?
    
    private enum CodingKeys: String, CodingKey {
        case podcastId
        case podcastName = "collectionName"
        case artist = "artistName"
        case type = "primaryGenreName"
        case feedUrl
        case podcastCoverImg="artworkUrl600"
        case imgDownloadIdentifier
        case imageDownloadUrl
        case releaseDate
    }
    
    init(){
        self.podcastName = ""
        self.podcastId=""
        self.artist = ""
        self.type=""
        self.feedUrl=""
        self.podcastCoverImg=""
        self.imageDownloadUrl=""
        
        
        
    }
    
}
