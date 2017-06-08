//
//  ViewController.swift
//  Platforms
//
//  Created by Richard Essemiah on 01/03/2017.
//  Copyright © 2017 Richard Essemiah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var studyLb: UILabel!
    @IBOutlet weak var lightsLb: UILabel!
    @IBOutlet weak var inTemp: UILabel!
    @IBOutlet weak var humLb: UILabel!
    
    
    let SWITCH_ON = "ON"
    let SWITCH_OFF = "OFF"
    
    var studyLedOn = false
    var mainLedOn = false
    var humValue: Int?
    var openHumd: Int?
    var openIcon1: String?
    var openTemp: Int?
    
    var timer: Timer!
    var getTemp = 2
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let weather = WeatherGetter()
        //weather.getWeather(city: "Amsterdam")
        updateFirebase()
        
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy.MM.dd"
        let result = formatter.string(from: date)
        print("today date is \(result)")
        
        
        
    }
        @IBAction func turnStudyLightsOn(_ sender: UIButton) {
        if studyLedOn == false {
            studyLedOn = true
            studyLed(led: "studyLed",state: SWITCH_ON)
            studyLb.text = SWITCH_ON
        }
        else {
            studyLedOn = false
            studyLed(led: "studyLed",state: SWITCH_OFF)
            studyLb.text = SWITCH_OFF
        }
    }

    @IBAction func turnMainLedOn(_ sender: UIButton) {
        if mainLedOn == false {
            mainLedOn = true
            studyLed(led: "mainLed",state: SWITCH_ON)
            lightsLb.text = SWITCH_ON
            
        }
        else {
            mainLedOn = false
            studyLed(led: "mainLed",state: SWITCH_OFF)
            lightsLb.text = SWITCH_OFF
            
        }
    }
    @IBAction func testtt(_ sender: UISwipeGestureRecognizer) {
        
        print("testtt")
    }
    @IBAction func backToBack(_ sender: Any) {
        performSegue(withIdentifier: "backToBack", sender: self)
    }
    @IBAction func getSecondView(_ sender: AnyObject) {
        performSegue(withIdentifier: "getWeatherInformation", sender: self)
    }
    // Get the data from firebase when the screenloads
    func updateFirebase() {
        let rootRef = FIRDatabase.database().reference()
        
        let mainLedState = rootRef.child("mainLed").child("state")
        let studyLedState = rootRef.child("studyLed").child("state")
        
        let tempRef = rootRef.child("dht22").child("temperature")
        let humdityRef = rootRef.child("dht22").child("humidity")
        
        let openHumdity = rootRef.child("openWeather").child("humidity")
        let openIcon = rootRef.child("openWeather").child("icon")
        let openTemperature = rootRef.child("openWeather").child("temperature")
        
        _ = studyLedState.observe(FIRDataEventType.value, with: { (snapshot) in
            let stateValue = snapshot.value as! String
            self.studyLb.text = stateValue
        })
        
        _ = mainLedState.observe(FIRDataEventType.value, with: { (snapshot) in
            let stateValue = snapshot.value as! String
            self.lightsLb.text = stateValue
        })
        if(self.studyLb.text == "OFF") {
            studyLedOn = false
        }
        else {
            studyLedOn = true
        }
        
        if(self.lightsLb.text == "OFF") {
            mainLedOn = false
        }
        else {
            mainLedOn = true
        }
        _ = tempRef.observe(FIRDataEventType.value, with: { (snapshot) in
            let tempValue = snapshot.value as! Int
            self.inTemp.text = String(describing: tempValue)
        })
        
        _ = humdityRef.observe(FIRDataEventType.value, with: { (snapshot) in
            self.humValue = snapshot.value as? Int
            self.humLb.text = String(describing: self.humValue!) + "%"
        })
        
        _ = openTemperature.observe(FIRDataEventType.value, with: { (snapshot) in
            self.openTemp = snapshot.value as? Int
            self.weatherTemp.text = String(describing: self.openTemp!)
        })
        
        _ = openHumdity.observe(FIRDataEventType.value, with: { (snapshot) in
            self.openHumd = snapshot.value as? Int
        })
        
        _ = openIcon.observe(FIRDataEventType.value, with: { (snapshot) in
            self.openIcon1 = snapshot.value as? String
            self.weatherIcon.downloadImg(from: "http://openweathermap.org/img/w/\(self.openIcon1!).png")
        })
    }
   
    // update study ledlamp in firebase
    func studyLed(led: String, state: String) {
        let ref = FIRDatabase.database().reference()
        let post : [String :AnyObject] = ["state" : state as AnyObject]
        ref.child(led).setValue(post)
    }
    
    

}

