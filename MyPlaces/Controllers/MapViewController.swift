//
//  MapViewController.swift
//  MyPlaces
//
//  Created by mac on 22.07.2023.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var place: Place!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlacemark()
    }

    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true)
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
}
