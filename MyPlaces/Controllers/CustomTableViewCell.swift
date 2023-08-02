//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by mac on 08.07.2023.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    //MARK: - Outlets

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
}
