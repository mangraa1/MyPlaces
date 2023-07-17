//
//  FilterViewController.swift
//  MyPlaces
//
//  Created by mac on 15.07.2023.
//

import UIKit

class SortedViewController: UITableViewController {

    //MARK: @IBOutlets & Variables

    @IBOutlet weak var segmentedControl: UISegmentedControl! // Will be used in future versions for UserDefaults
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageSwitch: UISwitch! // Will be used in future versions for UserDefaults

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

    @IBAction func reversedSorting(_ sender: UISwitch) {
        let  selectedOption = sender.isOn ? true : false

        if selectedOption {
            imageView.image = UIImage(named: "AZ")
        } else {
            imageView.image = UIImage(named: "ZA")
        }

        NotificationCenter.default.post(name: Notification.Name("ReversedSortingDidChanged"), object: selectedOption)
    }

    //MARK: - Table View delegate

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
