//
//  WeatherGetter.swift
//  Platforms
//
//  Created by Richard Essemiah on 02/03/2017.
//  Copyright © 2017 Richard Essemiah. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class WeatherGetter {
    var imageIcon: String?
    let KEVINTOCLESIUS = 272
    var temp_min: Int?
    var temp_max: Int?
    var desc: String?
    var type: String?
    
    // get weather infomation and send them into firebase
    func getWeather(city: String) {
        
        let rootRef = FIRDatabase.database().reference()
        let openHumdity1 = rootRef.child("openWeather").child("humidity")
        let openIcon2 = rootRef.child("openWeather").child("icon")
        let openTemperature1 = rootRef.child("openWeather").child("temperature")
        let openTemp_min = rootRef.child("openWeather").child("temp_min")
        let openTemp_max = rootRef.child("openWeather").child("temp_max")
        let openDescription = rootRef.child("openWeather").child("description")
        let openType = rootRef.child("openWeather").child("type")
        
        let weatherRequestURL = URL(string: "http://api.openweathermap.org/data/2.5/weather?&units=metric&q=\(city)&appid=1346fd1b3fefba9f54ab873ed18a2292")!
        
        // The data task retrieves the data.
        let dataTask = URLSession.shared.dataTask(with: weatherRequestURL) {
            (data, response, error) -> Void in
            if error == nil {
                
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                    
                    if let currentTemp = parsedData["main"] as? [String: AnyObject] {
                        
                        if let temp = currentTemp["temp"] as? Int {
                            
                            //self.temperature = String(temp1)
                            openTemperature1.setValue(temp)
                        }
                        
                        if let humd = currentTemp["humidity"] as? Int {
                            openHumdity1.setValue(humd)
                        }
                        
                        if let temp = currentTemp["temp_min"] as? Int {
                            self.temp_min = temp - self.KEVINTOCLESIUS
                            openTemp_min.setValue(self.temp_min!)
                        }
                        
                        if let temp = currentTemp["temp_max"] as? Int {
                            self.temp_max = temp - self.KEVINTOCLESIUS
                            openTemp_max.setValue(self.temp_max!)
                        }

                    }
                        if let weatherEntry = parsedData["weather"] as? NSArray {
                            if let weatherName = weatherEntry[0] as? [String: Any] {
                                self.imageIcon =  weatherName["icon"] as? String
                                openIcon2.setValue(self.imageIcon!)
                                self.desc = weatherName["description"] as? String
                                openDescription.setValue(self.desc!)
                                self.type = weatherName["main"] as? String
                                openType.setValue(self.type!)
                            }
                        }
                    
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        // The data task is set up...launch it!
        dataTask.resume()
    }
    
    
}
