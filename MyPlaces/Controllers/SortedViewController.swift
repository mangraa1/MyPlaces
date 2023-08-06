//
//  FilterViewController.swift
//  MyPlaces
//
//  Created by mac on 15.07.2023.
//

import UIKit

class SortedViewController: UITableViewController {

    //MARK: @IBOutlets & Variables

    var ascendingSorting = true

    @IBOutlet weak var segmentedControl: UISegmentedControl! // Will be used in future versions for UserDefaults
    @IBOutlet weak var imageView: UIImageView!

    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - @IBAction

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        let selectedOption = sender.selectedSegmentIndex

        NotificationCenter.default.post(name: Notification.Name("SortSelectionDidChanged"), object: selectedOption)
    }

    //MARK: - Table View delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            var selectedOption = true

            ascendingSorting.toggle()

            if ascendingSorting {
                imageView.image = UIImage(named: "AZ")
                selectedOption = false
            } else {
                imageView.image = UIImage(named: "ZA")
                selectedOption = true
            }

            NotificationCenter.default.post(name: Notification.Name("ReversedSortingDidChanged"), object: selectedOption)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    deinit {
        print("deinit", SortedViewController.self)
    }
}
