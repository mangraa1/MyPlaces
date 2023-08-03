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

    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifire = ""
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { currentLocation in

                self.previousLocation = currentLocation

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
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
    }

    //MARK: - @IBAction

    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }

    @IBAction func goButtonPressed(_ sender: Any) {
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }

    //MARK: - Private

    private func setupMapView() {

        goButton.isHidden = true

        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifire) {
            mapManager.locationManager.delegate = self
        }

        if incomeSegueIdentifire == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }

    deinit {
        print("deinit", MapViewController.self)
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
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()

        // Automatic camera zoom to the user's location
        if incomeSegueIdentifire == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.mapManager.showUserLocation(mapView: mapView)
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
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifire: incomeSegueIdentifire)
    }
}
