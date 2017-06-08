//
//  HomePageViewController.swift
//  Platforms
//
//  Created by Richard Essemiah on 11/04/2017.
//  Copyright © 2017 Richard Essemiah. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseDatabase
import CoreLocation
import MapKit

class HomePageViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var homeTeamLb: UILabel!
    @IBOutlet weak var goalsLb: UILabel!
    @IBOutlet weak var awayTeamLb: UILabel!
    @IBOutlet weak var tempLb: UILabel!
    @IBOutlet weak var matchdayLb: UILabel!
    
    
    
    let headers: HTTPHeaders = [
        "Ocp-Apim-Subscription-Key": "60607b037d334565be2700c93862405c"
        
    ]
    var myWeek: Int?
    var runGetStands: Timer!
    var openTemp: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getCurrentWeek()

        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        var currentLocation: CLLocation!
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            currentLocation = locManager.location!
            print("Location hello %%%%%%%@@@@@@@@@@@@@@  \(currentLocation.coordinate.latitude)")
            print(currentLocation.coordinate.longitude)
        }
        
        let rootRef = FIRDatabase.database().reference()
        
        let openTemperature = rootRef.child("openWeather").child("temperature")
        
        _ = openTemperature.observe(FIRDataEventType.value, with: { (snapshot) in
            self.openTemp = snapshot.value as? Int
            self.tempLb.text = String(describing: self.openTemp!)
        })
        
    }

    @IBAction func myRoomController(_ sender: UIButton) {
        performSegue(withIdentifier: "performMyRoom", sender: self)
    }
    @IBAction func myScheduleGames(_ sender: Any) {
        performSegue(withIdentifier: "scheduleGames", sender: self)
    }
    
    func getCurrentWeek() {
        
        var week: Int?
        let rootRef = FIRDatabase.database().reference()
        
        rootRef.child("soccer").child("currentWeek").observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
            week = snapshot.value! as? Int
            self.myWeek = week!
            
            self.getStands()
        })

        
    }
    
    func getStands() {
        let rootRef = FIRDatabase.database().reference()
        
        rootRef.child("soccer").child("schedule").child("\(self.myWeek!)").queryOrderedByKey().observe(FIRDataEventType.childAdded,   with: { snapshot in
            let games = snapshot.value as? [String : AnyObject]
            
            let awayKey = games?["awayteamkey"] as? String
            let homeKey = games?["hometeamkey"] as? String
            let awayName = games?["awayteamname"] as? String
            let homeName = games?["hometeamname"] as? String
            let awayGoals = games?["awayteamscore"] as? Int
            let homeGoals = games?["hometeamscore"] as? Int

            
            if homeKey == "CFC" || awayKey == "CFC" {
                
                rootRef.child("soccer").child("teams").child(awayKey!).observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
                    
                    let team = snapshot.value as? [String : AnyObject]
                    let awayName = team?["teamName"] as? String
                    self.awayTeamLb.text = awayName!
                })
                
                rootRef.child("soccer").child("teams").child(homeKey!).observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
                    
                    let team = snapshot.value as? [String : AnyObject]
                    let homeName = team?["teamName"] as? String
                    self.homeTeamLb.text = homeName!
                })
                    var scores: AnyObject?
                    
                    if awayGoals == 999 {
                        scores = "-" as AnyObject
                    }
                    else {
                        scores = "\(homeGoals!) - \(awayGoals!)" as AnyObject
                    }
                    self.goalsLb.text = scores as! String
                
            }
        
        })
    }
}



