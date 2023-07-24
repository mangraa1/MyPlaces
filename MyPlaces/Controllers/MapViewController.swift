//
//  MapViewController.swift
//  MyPlaces
//
//  Created by mac on 22.07.2023.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var place = Place()
    let annotationIdentifier = "annotationIdentifier"

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

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
