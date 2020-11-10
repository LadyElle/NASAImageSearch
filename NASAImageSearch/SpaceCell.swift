//
//  SpaceCell.swift
//  MichelleStaffordCodingChallenge
//
//  Created by Michelle Stafford on 2019-04-02.
//  Copyright © 2019 Michelle Stafford. All rights reserved.
//

import UIKit

class SpaceCell: UITableViewCell {
    @IBOutlet var spaceImageView: UIImageView!
    @IBOutlet var spaceTitleLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setSpacePreviewDetails(with: .none)
    }
    
    func setSpacePreviewDetails(with space: Space?){
        if let space = space{
            spaceImageView.image = space.image
            spaceTitleLabel.text = space.title
            spaceImageView.alpha = 1
            spaceTitleLabel.alpha = 1
            indicatorView.stopAnimating()
        }
        else{
            spaceImageView.alpha = 0
            spaceTitleLabel.alpha = 0
            indicatorView.startAnimating()
        }
    }
}
