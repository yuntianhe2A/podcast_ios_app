//
//  PodcastImage+CoreDataProperties.swift
//  FinalAssignment
//
//  Created by Yansong Li on 11/6/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//
//

import Foundation
import CoreData


extension PodcastImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PodcastImage> {
        return NSFetchRequest<PodcastImage>(entityName: "PodcastImage")
    }

    @NSManaged public var imageName: String?

}
