//
//  FirstViewController.swift
//  Beacon
//
//  Created by Cody Zeng on 11/12/17.
//  Copyright © 2017 Cody Zeng. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import TwitterKit

class FirstViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    @IBOutlet weak var tweetListSubView: UIView!
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
        print("MAKING REQUEST =========>")
//        Alamofire.request( "http://localhost:3000/events", parameters: ["lat": 37.8756, "lng":-122.2588, "distance": 1000, "sort": "time", "accessToken": "1861168064194536|QD4ThBLg1lAfv8ZjGfjGd2M9DN0"])
//            .response { data in
//                //print(request)
//                print(data)
//                //print(error)
//        }
//        Alamofire.request("https://httpbin.org/get").responseJSON { response in
//            debugPrint(response)
//
//            if let json = response.result.value {
//                print("JSON: \(json)")
//            }
//        }
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": " ", "geocode":"37.8756,-122.2588,.5km", "result_type": "recent"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError)")
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = json as? [String: Any] {
                   // print("ARR IS :  \(dictionary)")
//                    if let statusesArr = dictionary["statuses"] as? [NSArray] {
//                        statusesArr.forEach { item in
//                            print("ITEM IS \(item)")
//                        }
//                    }
                    
                    if let array = dictionary["statuses"] as? [Any] {
                        for object in array {
                            if let obj = object as? [String:Any] {
                                print("TEXT IS \(obj["text"]!)")
                                print("CREATED AT IS \(obj["created_at"]!)")
                                if let user = obj["user"]! as? [String:Any] {
                                    print("USER IS \(user["screen_name"]!)")
                                }
//                                if let entities = obj["entities"]! as? [String:Any] {
//                                    if (entities != nil) {
//                                        if let media = entities["media"]! as? [String:Any] {
//                                            print("URL IS \(media["expanded_url"]!)")
//
//                                        }
//                                    }
//
//                                }
                                
                            }
                        }
                         print("ARR IS :  \(array)")

                    }
                    let tweetView = TWTRTweetView()
                    client.loadTweet(withID: "20") { (tweet, error) in
                        if let t = tweet {
                            tweetView.configure(with: t)
                            self.tweetListSubView.addSubview(tweetView)
                        } else {
                            print("Failed to load Tweet: \(error?.localizedDescription)")
                        }
                    }

                    
//                    for (key, value) in dictionary {
//                        print("STATUS IS : \(key)  \(value)")
//
//                    }
                }
                //print("json: \(json)")
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }

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

