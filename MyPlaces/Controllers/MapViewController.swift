//
//  MapViewController.swift
//  MyPlaces
//
//  Created by mac on 22.07.2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1_000
    var incomeSegueIdentifire = ""

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        setupMapView()
        checkLocationServices()
    }

    //MARK: - @IBAction

    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
    }

    //MARK: - Private

    private func setupMapView() {
        if incomeSegueIdentifire == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            address.isHidden = true
            doneButton.isHidden = true
        }
    }

    private func setupPlacemark() {

        guard let location = place.location else { return }

        // Сonverting location to geographic coordinates
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in

            if let _ = error {
                print("geocoder error")
                return
            }

            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first // Marker on map

            // A description of the point the marker points to
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type

            // Linking the description to a specific point on the map
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate

            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    private func checkLocationServices() {

        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showLocationServicesAlert()
            }
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {

        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifire == "getAddress" { showUserLocation() }

        case .denied:
            showAlert(title: "Location access denied",
                      message: "To display your location on the map, allow access in the device settings.")

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .restricted:
            showAlert(title: "Access to geolocation is limited",
                      message: "Access to geolocation is limited by device settings.")

        case .authorizedAlways:
            break

        @unknown default:
            print("New case is available")
        }
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    private func showLocationServicesAlert() {
        let alertController = UIAlertController(title: "Location Services is disabled",
                                                message: "Turn on location services on your device",
                                                preferredStyle: .alert)

        // Transfer user to phone settings
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        [settingsAction, cancelAction].forEach { alertController.addAction($0) }
        present(alertController, animated: true)
    }

    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
}

//MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Сhecking if this is the user's location
        guard !(annotation is MKUserLocation) else { return nil }

        // Create view with map annotation
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }

        // Adding a photo to an annotation
        if let imageData = place.imageData {

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 37, height: 37))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)

            annotationView?.rightCalloutAccessoryView = imageView
        }

        return annotationView
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
