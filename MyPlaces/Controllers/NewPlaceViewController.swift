//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by mac on 10.07.2023.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Table View delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0 {

        } else {
            view.endEditing(true)
        }
    }
}

//MARK: - Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {

    //hide the keyboard on click on Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
