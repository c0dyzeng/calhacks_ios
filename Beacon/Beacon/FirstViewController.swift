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

class FirstViewController: UIViewController, TWTRTweetViewDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    // table stuff
    
    @IBOutlet weak var tableView: UITableView!
    // setup a 'container' for Tweets
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var tweetIDs: [Any] = [];
    
    var prototypeCell: TWTRTweetTableViewCell?
    
    let tweetTableCellReuseIdentifier = "TweetCell"
    
    var isLoadingTweets = false
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make sure the navigation bar is not translucent when scrolling the table view.
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    
    func loadTweets() {
        findTweetIDs { () in
            // Find the tweets with the tweetIDs
            let client = TWTRAPIClient()
            client.loadTweets(withIDs: self.tweetIDs) { (twttrs, error) -> Void in
                
                
                // If there are tweets do something magical
                if ((twttrs) != nil) {
                    // Loop through tweets and do something
                    self.tweets = []
                    for i in twttrs! {
                        // Append the Tweet to the Tweets to display in the table view.
                        self.tweets.append(i as TWTRTweet)
                    }
                } else {
                    print(error as Any)
                }
            }
        }
    }
    
    func findTweetIDs(completion: @escaping () -> ()) {
        // set tweetIds to find
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let lat = String(currCenter.latitude)
        let lon = String(currCenter.longitude)
        let rad = String(currRadiusMeters/1000) + "km"
        let params = ["q": " ", "geocode":lat + "," + lon + "," + rad, "result_type": "recent"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(String(describing: connectionError))")
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = json as? [String: Any] {
                    
                    if let array = dictionary["statuses"] as? [Any] {
                        // iterate through tweet objects in array to get their text, created at, user, screen name
                        self.tweetIDs = []
                        for object in array {
                            if let obj = object as? [String:Any] {
                                self.tweetIDs.append(String(describing: obj["id"]!))
                            }
                        }
                        
                    }
                }
                completion()
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
            
        }
    }
    
    func refreshInvoked() {
        // Trigger a load for the most recent Tweets.
        loadTweets()
        tableView.reloadData()
    }
    
    // MARK: TWTRTweetViewDelegate
    func tweetView(_ tweetView: TWTRTweetView!, didSelect tweet: TWTRTweet!) {
        // Display a Web View when selecting the Tweet.
        let webViewController = UIViewController()
        let webView = UIWebView(frame: webViewController.view.bounds)
        webView.loadRequest(URLRequest(url: tweet.permalink))
        webViewController.view = webView
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of Tweets.
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve the Tweet cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableCellReuseIdentifier, for: indexPath) as! TWTRTweetTableViewCell
        
        // Assign the delegate to control events on Tweets.
        cell.tweetView.delegate = self
        
        // Retrieve the Tweet model from loaded Tweets.
        let tweet = tweets[indexPath.row]
        
        // Configure the cell with the Tweet.
        cell.configure(with: tweet)
        
        // Return the Tweet cell.
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tweet = self.tweets[indexPath.row]
        self.prototypeCell?.configure(with: tweet)
        
        return TWTRTweetTableViewCell.height(for: tweet, style: TWTRTweetViewStyle.compact, width: self.view.bounds.width, showingActions: false)
    }
    
    // map stuff
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    var currRadiusMeters: Double = 500.0
    var currCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.8756, longitude: -122.2588)
    
    @IBOutlet weak var tweetListSubView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableview stuff
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        // Create a single prototype cell for height calculations.
        self.prototypeCell = TWTRTweetTableViewCell(style: .default, reuseIdentifier: tweetTableCellReuseIdentifier)
        
        // Register the identifier for TWTRTweetTableViewCell.
        self.tableView.register(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableCellReuseIdentifier)
        
        // Setup table data
        loadTweets()
        
        // map stuff
        let initialLoc = CLLocation(latitude: 37.8722, longitude: -122.2596)
        centerMapOnLocation(location: initialLoc)
        
        let pinSoda = MKPointAnnotation()
        pinSoda.coordinate = CLLocationCoordinate2D(
                latitude: 37.8756,
                longitude: -122.2588)
        pinSoda.title = "Soda Hall"
        pinSoda.subtitle = "eecs"
        mapView.addAnnotation(pinSoda)
        
        let pinFollow = MKPointAnnotation()
        pinFollow.coordinate = CLLocationCoordinate2D(
            latitude: 16.70555,
            longitude: -62.21729)
        pinFollow.title = "you!"
        pinFollow.subtitle = "follow me on instagram"
        mapView.addAnnotation(pinFollow)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion =
            MKCoordinateRegionMakeWithDistance(
                location.coordinate,
                regionRadius * 2.0,
                regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // when map region changes, update currCenter currRadiusMeters
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // update global vars
        currCenter = mapView.centerCoordinate
        let mpTopRight = MKMapPointMake(
            mapView.visibleMapRect.origin.x + mapView.visibleMapRect.size.width,
            mapView.visibleMapRect.origin.y)
        let mpBottomRight = MKMapPointMake(
            mapView.visibleMapRect.origin.x + mapView.visibleMapRect.size.width,
            mapView.visibleMapRect.origin.y + mapView.visibleMapRect.size.height)
        currRadiusMeters = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 2
        // redraw circle
        self.mapView.removeOverlays(self.mapView.overlays)
        addRadiusCircle()
        refreshInvoked()
    }
    
    func addRadiusCircle(){
        self.mapView.delegate = self
        let circle = MKCircle(center: currCenter, radius: currRadiusMeters)
        self.mapView.add(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self) {
            let view = MKCircleRenderer(overlay: overlay)
            view.fillColor = UIColor.blue.withAlphaComponent(0.1)
            return view
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

