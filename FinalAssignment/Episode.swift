//
//  Episode.swift
//  FinalAssignment
//
//  Created by Yansong Li on 21/5/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//

import Foundation
class Episode:NSObject{
     
    var episodeTitle:String?
    var episodeDescription:String?
    var enclosure:Enclosure?
    var duration:String?
    
     private enum CodingKeys: String, CodingKey {
         case episodeTitle
         case episodeDescription
         case enclosure
        case duration = "itunes:duration"
       }
}
class Enclosure:NSObject{
    var url:String?
    var length:String?
}

