//
//  RatingControl.swift
//  MyPlaces
//
//  Created by mac on 19.07.2023.
//

import UIKit
import SnapKit

@IBDesignable class RatingControl: UIStackView {

    //MARK: - Properties

    private var ratingButtons = [UIButton]()

    var rating = 0

    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

    //MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        setupButtons()
    }

    //MARK: - Button Action

    @objc func ratingButtonTapped(button: UIButton) {
        print("tapped")
    }

    //MARK: - Private Methods

    private func setupButtons() {

        for button in ratingButtons {
            removeArrangedSubview(button)
        }
        ratingButtons.removeAll()

        for _ in 0 ..< starCount {
            // Create the button
            let button = UIButton()
            button.backgroundColor = .systemBlue

            // Add constraints
            button.snp.makeConstraints { make in
                make.height.equalTo(starSize.height)
                make.width.equalTo(starSize.width)
            }

            // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)

            // Add the button to stack
            addArrangedSubview(button)

            //Add the new button on the rating button array
            ratingButtons.append(button)
        }
    }
}
