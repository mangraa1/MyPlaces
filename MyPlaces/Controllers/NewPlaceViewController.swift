//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by mac on 10.07.2023.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    //MARK: @IBOutlets & Variables

    var imageIsChanged = false
    var currentPlace: Place! // "Place" to which the transition will be made when clicking on the cell
    
    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!

    @IBOutlet weak var ratingControl: RatingControl!

    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupEditScreen()
        saveButton.isEnabled = false
        setupEditScreen()

        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    //MARK: - Table View delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Causes an Alert, which provides the ability to add a photo
        if indexPath.row == 0 {
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photo")

            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

            let gallery = UIAlertAction(title: "Gallery", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            gallery.setValue(photoIcon, forKey: "image")
            gallery.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

            let cancel = UIAlertAction(title: "Cancel", style: .cancel)

            [camera, gallery, cancel].forEach { actionSheet.addAction($0) }

            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    //MARK: - Save place

    func savePlace() {
        var image: UIImage?

        // Setting a default photo in case the user does not select his photo
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = UIImage(named: "imagePlaceholder")
        }

        let imageData = image?.pngData()

        // Creating a new location with the data entered by the user (data taken from NewPlace VC)
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))

        if currentPlace != nil { // Updating old value
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else { // Entering into the database new value
            StorageManager.saveObject(newPlace)
        }
    }

    //MARK: - Setup edit screen

    private func setupEditScreen() {
        if currentPlace != nil {
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }

            setupNavigationBar()
            imageIsChanged = true

            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
        }
    }

    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem()
        }

        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }

    //MARK: - @IBAction

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

//MARK: - Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {

    // Hide the keyboard on click on Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // Is responsible for accessing the saveButton click
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

//MARK: - Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // The ability to add photos from the gallery or camera
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }

    // UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Sets photo to imageOfPlace
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true

        imageIsChanged = true

        dismiss(animated: true)
    }
}
