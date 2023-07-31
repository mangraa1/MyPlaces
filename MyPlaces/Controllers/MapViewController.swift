//
//  MapViewController.swift
//  MyPlaces
//
//  Created by mac on 22.07.2023.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

    //MARK: @IBOutlets & Variables

    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var incomeSegueIdentifire = ""
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray = [MKDirections]()
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        addressLabel.text = ""

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

    @IBAction func goButtonPressed(_ sender: Any) {
        getDirections()
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }

    //MARK: - Private

    private func setupMapView() {

        goButton.isHidden = true

        if incomeSegueIdentifire == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }

    private func resetMapView(withNew directions: MKDirections) {

        // Deleting the current route overlay before building a new one
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() } // Route cancellation
        directionsArray.removeAll()
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
            self.placeCoordinate = placemarkLocation.coordinate

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

    private func startTrackingUserLocation() {

        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showUserLocation()
        }
    }

    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {

        let latitude = mapView.centerCoordinate.latitude
        let lognitude = mapView.centerCoordinate.longitude

        return CLLocation(latitude: latitude, longitude: lognitude)
    }

    private func getDirections() {

        // User location coordinates
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }

        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        // Routing request
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }

        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)

        // Route calculation
        directions.calculate { (response, error) in

            if let error = error {
                print(error)
            }

            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }

            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime

                print("Distance to place: \(distance) km.")
                print("Travel time will be: \(timeInterval) sec.")
            }
        }
    }

    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {

        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)

        // Route parameters
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile

        return request
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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()

        // Automatic camera zoom to the user's location
        if incomeSegueIdentifire == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.showUserLocation()
            }
        }

        geocoder.cancelGeocode()

        // Converting coordinates to address
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in

            if let _ = error {
                print("geocoder error")
                return
            }

            guard let placemarks = placemarks else { return }

            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare

            // Point address display
            DispatchQueue.main.async {
                var addressText = ""

                if let streetName = streetName, let buildNumber = buildNumber  {
                    addressText += "\(streetName), \(buildNumber)"
                } else if let streetName = streetName {
                    addressText += "\(streetName)"
                }
                self.addressLabel.text = addressText
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        // Route display
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue

        return renderer
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
