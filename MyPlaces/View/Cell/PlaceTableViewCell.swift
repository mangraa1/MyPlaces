//
//  PlaceTableViewCell.swift
//  MyPlaces
//
//  Created by mac on 08.07.2023.
//

import UIKit
import SnapKit

class PlaceTableViewCell: UITableViewCell {

    //MARK: - Variables

    let photo = UIImageView()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)

        return label
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - private func

    private func setupCell() {

        [photo, nameLabel].forEach { contentView.addSubview($0) }

        photo.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView.snp.top).inset(5)
            make.left.equalTo(contentView.snp.left).offset(14)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(photo.snp.centerX)
            make.left.equalTo(photo.snp.right).offset(8)
            make.right.equalTo(contentView.snp.right).offset(-8)
        }
    }

    //MARK: - public func

    func configure(place: Place) {
        photo.image = UIImage(named: place.name ?? "doc.badge.plus")
        nameLabel.text = place.name
    }
}

