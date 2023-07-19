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

    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }

    private var ratingButtons = [UIButton]()

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
        guard let index = ratingButtons.firstIndex(of: button) else { return }

        // Calculate the rating of the selected button
        let selectedRating = index + 1

        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }

    //MARK: - Private Methods

    private func setupButtons() {

        for button in ratingButtons {
            removeArrangedSubview(button)
        }
        ratingButtons.removeAll()

        // Load button image
        let bundle = Bundle(for: type(of: self))
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)

        for _ in 0 ..< starCount {

            let button = UIButton()

            // Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])

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

        updateButtonSelectionState()
    }

    private func updateButtonSelectionState() { // Fills all the stars up to the selected one
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
