//
//  DownloadedAudio+CoreDataProperties.swift
//  FinalAssignment
//
//  Created by Yansong Li on 11/6/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//
//

import Foundation
import CoreData


extension DownloadedAudio {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadedAudio> {
        return NSFetchRequest<DownloadedAudio>(entityName: "DownloadedAudio")
    }

    @NSManaged public var filePath: String?

}
