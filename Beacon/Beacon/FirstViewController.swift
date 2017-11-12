//
//  FirstViewController.swift
//  Beacon
//
//  Created by Cody Zeng on 11/12/17.
//  Copyright © 2017 Cody Zeng. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hardcode initial location
        // TODO later: instead access user location, center there
        let initialLoc = CLLocation(latitude: 37.8722, longitude: -122.2596)
        centerMapOnLocation(location: initialLoc)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(
                latitude: 37.8756,
                longitude: -122.2588)
        annotation.title = "Soda Hall"
        annotation.subtitle = "eecs"
        mapView.addAnnotation(annotation)
        
        // TODO : figure out how to customize pins
//        let annotationView = MKPinAnnotationView()
//        annotationView.pinTint
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion =
            MKCoordinateRegionMakeWithDistance(
                location.coordinate,
                regionRadius * 2.0,
                regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

