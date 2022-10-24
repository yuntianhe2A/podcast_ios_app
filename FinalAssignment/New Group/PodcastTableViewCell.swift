//
//  ShowListTableViewCell.swift
//  FinalAssignment
//
//  Created by Yansong Li on 20/5/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellImgView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var podcastNameLabel: UILabel!
    @IBOutlet weak var podcastArtistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
