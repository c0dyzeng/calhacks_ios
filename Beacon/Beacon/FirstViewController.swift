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

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TWTRTweetViewDelegate {

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
        // Do not trigger another request if one is already in progress.
        if self.isLoadingTweets {
            return
        }
        self.isLoadingTweets = true
        
        findTweetIDs { () in
            // Find the tweets with the tweetIDs
            let client = TWTRAPIClient()
            print("TWEET IDS ARE: \(self.tweetIDs)")
            
            client.loadTweets(withIDs: self.tweetIDs) { (twttrs, error) -> Void in
                
                
                // If there are tweets do something magical
                if ((twttrs) != nil) {
                    print("TWEETS ARE: \(twttrs)")
                    // Loop through tweets and do something
                    for i in twttrs! {
                        // Append the Tweet to the Tweets to display in the table view.
                        self.tweets.append(i as TWTRTweet)
                    }
                } else {
                    print(error as Any)
                }
            }
        }
        
        //        // Find the tweets with the tweetIDs
        //        let client = TWTRAPIClient()
        //        print("TWEET IDS ARE: \(self.tweetIDs)")
        //
        //        client.loadTweets(withIDs: self.tweetIDs) { (twttrs, error) -> Void in
        //            print("TWEETS ARE: \(twttrs)")
        //
        //            // If there are tweets do something magical
        //            if ((twttrs) != nil) {
        //
        //                // Loop through tweets and do something
        //                for i in twttrs! {
        //                    // Append the Tweet to the Tweets to display in the table view.
        //                    self.tweets.append(i as TWTRTweet)
        //                }
        //            } else {
        //                print(error as Any)
        //            }
        //        }
        
    }
    
    func findTweetIDs(completion: @escaping () -> ()) {
        // set tweetIds to find
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": " ", "geocode":"37.8756,-122.2588,.5km", "result_type": "recent"]
        //        var tweetIDs: [Any] = [];
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
                        // iterate through tweet objects in array to get their text, created at, user, screen name
                        self.tweetIDs = []
                        for object in array {
                            if let obj = object as? [String:Any] {
                                self.tweetIDs.append(String(describing: obj["id"]!))
                            }
                        }
                        print("ARR IS :  \(self.tweetIDs)")
                        
                    }
                }
                completion()
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
            
        }
        //return tweetIDs
    }
    
    func refreshInvoked() {
        // Trigger a load for the most recent Tweets.
        loadTweets()
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
        
        
        
        // nithi hardcoded post
//        let client = TWTRAPIClient()
//        let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
//        let params = ["q": " ", "geocode":"37.8756,-122.2588,.5km", "result_type": "recent"]
//        var clientError : NSError?
//
//        let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
//
//        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
//            if connectionError != nil {
//                print("Error: \(connectionError)")
//            }
//
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: [])
//                if let dictionary = json as? [String: Any] {
//                   // print("ARR IS :  \(dictionary)")
////                    if let statusesArr = dictionary["statuses"] as? [NSArray] {
////                        statusesArr.forEach { item in
////                            print("ITEM IS \(item)")
////                        }
////                    }
//
//                    if let array = dictionary["statuses"] as? [Any] {
//                        // iterate through tweet objects in array to get their text, created at, user, screen name
//                        for object in array {
//                            if let obj = object as? [String:Any] {
//                                print("TEXT IS \(obj["text"]!)")
//                                print("CREATED AT IS \(obj["created_at"]!)")
//                                if let user = obj["user"]! as? [String:Any] {
//                                    print("USER IS \(user["screen_name"]!)")
//                                }
////                                if let entities = obj["entities"]! as? [String:Any] {
////                                    if (entities != nil) {
////                                        if let media = entities["media"]! as? [String:Any] {
////                                            print("URL IS \(media["expanded_url"]!)")
////
////                                        }
////                                    }
////
////                                }
//
//                            }
//                        }
//                         print("ARR IS :  \(array)")
//
//                    }
//
//                    //TODO: delete this hardcoded thing and make it a list of tweets
//                    let tweetView = TWTRTweetView()
//                    client.loadTweet(withID: "933775988894208000") { (tweet, error) in
//                        if let t = tweet {
//                            tweetView.configure(with: t)
//                            tweetView.bounds = self.tweetListSubView.bounds
//                            tweetView.center = self.tweetListSubView.center
//                            self.view.addSubview(tweetView)
//                        } else {
//                            print("Failed to load Tweet: \(error?.localizedDescription)")
//                        }
//                    }
//
//
////                    for (key, value) in dictionary {
////                        print("STATUS IS : \(key)  \(value)")
////
////                    }
//                }
//                //print("json: \(json)")
//            } catch let jsonError as NSError {
//                print("json error: \(jsonError.localizedDescription)")
//            }
//        }
//
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion =
            MKCoordinateRegionMakeWithDistance(
                location.coordinate,
                regionRadius * 2.0,
                regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }


}

