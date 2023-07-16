//
//  FilterViewController.swift
//  MyPlaces
//
//  Created by mac on 15.07.2023.
//

import UIKit

class SortedViewController: UITableViewController {

    //MARK: @IBOutlets & Variables

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!


    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //MARK: - Save filter settings
    
    func saveFilterSettings() {

    }

    //MARK: - @IBAction

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func sortSelection(_ sender: UISegmentedControl) {
    }

    //MARK: - Table View delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            //TODO: - action to reverse
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
