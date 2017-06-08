//
//  WeatherViewController.swift
//  Platforms
//
//  Created by Richard Essemiah on 05/03/2017.
//  Copyright © 2017 Richard Essemiah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class WeatherViewController: UIViewController {

    @IBOutlet weak var cityLb: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherLb: UILabel!
    @IBOutlet weak var typeWeatherLb: UILabel!
    @IBOutlet weak var temp_minimaal: UILabel!
    @IBOutlet weak var temp_maximaal: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var humidityLb: UILabel!
    
    var openHumd: Int?
    var openIcon1: String?
    var openTemp: Int?
    var humidityValue: Int?
    let KEVINTOCLESIUS = 272
    var temp_min: Int?
    var temp_max: Int?
    var weatherDesc: String?
    var type: String?
    var location: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let weather = WeatherGetter()
        getWeatherInfo()
        cityLb.text = ""
        
    }

    @IBAction func getMyRoom(_ sender: UIButton) {
        performSegue(withIdentifier: "getRoom", sender: self)
    }
    
    func getWeatherInfo() {
        let rootRef = FIRDatabase.database().reference()
        let openHumdity = rootRef.child("openWeather").child("humidity")
        let openIcon = rootRef.child("openWeather").child("icon")
        let openTemperature = rootRef.child("openWeather").child("temperature")
        let openTemp_min = rootRef.child("openWeather").child("temp_min")
        let openTemp_max = rootRef.child("openWeather").child("temp_max")
        let openDescription = rootRef.child("openWeather").child("description")
        let openType = rootRef.child("openWeather").child("type")
        

        
        rootRef.child("openWeather").child("temperature").observe(FIRDataEventType.value, with: { (snapshot) in
            self.openTemp = snapshot.value as? Int
            self.weatherLb.text = String(describing: self.openTemp!) + "°"
        })
        
        _ = openHumdity.observe(FIRDataEventType.value, with: { (snapshot) in
            self.humidityValue =  snapshot.value as? Int
            self.humidityLb.text = String(describing:  self.humidityValue!) + "%"
        })
        
        _ = openTemp_min.observe(FIRDataEventType.value, with: { (snapshot) in
            self.temp_min =  snapshot.value as? Int
            self.temp_minimaal.text = String(describing:  self.temp_min!) + "°"
        })
        
        _ = openTemp_max.observe(FIRDataEventType.value, with: { (snapshot) in
            self.temp_max =  snapshot.value as? Int
            self.temp_maximaal.text = String(describing:  self.temp_max!) + "°"
        })
        
        
        
        _ = openType.observe(FIRDataEventType.value, with: { (snapshot) in
            self.type =  snapshot.value as? String
            self.typeWeatherLb.text = self.type!
        })
        
        _ = openDescription.observe(FIRDataEventType.value, with: { (snapshot) in
            self.weatherDesc =  snapshot.value as? String
            let text = "Today: \(self.weatherDesc!) currently. The high will be \(self.temp_max!) °"
            print (text)
            self.desc.text = text
        })
        
        rootRef.child("openWeather").child("location").observe(FIRDataEventType.value, with: { (snapshot) in
            self.location = snapshot.value as? String
            self.cityLb.text = self.location!
        
        })
    }
    
    
    
   
   

}
