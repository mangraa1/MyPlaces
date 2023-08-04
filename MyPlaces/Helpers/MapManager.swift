//
//  MapManager.swift
//  MyPlaces
//
//  Created by mac on 02.08.2023.
//

import UIKit
import MapKit

class MapManager {

    let locationManager = CLLocationManager()

    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters: Double = 500
    private var directionsArray = [MKDirections]()

    //MARK: - Methods

    func setupPlacemark(place: Place, mapView: MKMapView) {

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
            annotation.title = place.name
            annotation.subtitle = place.type

            // Linking the description to a specific point on the map
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate

            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifire: segueIdentifier)
            // Assign a delegate if the user has allowed geolocation tracking
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showLocationServicesAlert()
            }
        }
    }

    func checkLocationAuthorization(mapView: MKMapView, segueIdentifire: String) {
        switch locationManager.authorizationStatus {

        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifire == "getAddress" { showUserLocation(mapView: mapView) }

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

    // Map focus on the user's location
    func showUserLocation(mapView: MKMapView) {

        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }

    // Build a route from the user's location to the institution
    func getDirections(for mapView: MKMapView, label: UILabel, previousLocation: (CLLocation) -> ()) {

        // User location coordinates
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }

        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))

        // Routing request
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }

        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)

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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = self.formatSeconds(Int(route.expectedTravelTime))

//                print("Distance to place: \(distance) km.")
//                print("Travel time will be: \(timeInterval) min.")
                label.text = " Distance to place: \(distance) km. \n Travel time will be: \(timeInterval) min."
            }
        }
    }

    // Setting up a request for route calculation
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {

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

    // Change the displayed area of the map in accordance with the movement of the user
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {

        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }

        // Location update after some time
        closure(center)
    }

    // Кesetting all previously built routes before building a new one
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {

        // Deleting the current route overlay before building a new one
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() } // Route cancellation
        directionsArray.removeAll()
    }

    // Determining the center of the displayed area of the map
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {

        let latitude = mapView.centerCoordinate.latitude
        let lognitude = mapView.centerCoordinate.longitude

        return CLLocation(latitude: latitude, longitude: lognitude)
    }

    //MARK: - Alerts
    private func showAlert(title: String, message: String) {

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)

        alertWindow(for: alertController)
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

        alertWindow(for: alertController)
    }

    private func alertWindow(for alert: UIAlertController) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }

    //MARK: - Time format

    private func formatSeconds(_ seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        if seconds >= 3600 {
            let hours = seconds / 3600
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }

    deinit {
        print("deinit", MapManager.self)
    }
}
