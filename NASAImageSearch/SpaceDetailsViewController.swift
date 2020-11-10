//
//  SpaceDetailsViewController.swift
//  MichelleStaffordCodingChallenge
//
//  Created by Michelle Stafford on 2019-04-03.
//  Copyright © 2019 Michelle Stafford. All rights reserved.
//

import UIKit

class SpaceDetailsViewController: UIViewController {
    @IBOutlet weak var spaceImage: UIImageView!
    @IBOutlet weak var spaceTitle: UILabel!
    @IBOutlet weak var spaceDateCreated: UILabel!
    @IBOutlet weak var spaceDescription: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    var spaceDetail: Space? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let spaceDetail = spaceDetail {
            if let spaceDescription = spaceDescription, let spaceImage = spaceImage, let spaceTitle = spaceTitle, let spaceDateCreated = spaceDateCreated {
                spaceTitle.text = spaceDetail.title
                spaceDescription.text = spaceDetail.description
                spaceImage.image = spaceDetail.image
                spaceDateCreated.text = spaceDetail.dateCreated
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
}
