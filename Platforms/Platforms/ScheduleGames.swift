//
//  ScheduleGames.swift
//  Platforms
//
//  Created by Richard Essemiah on 21/04/2017.
//  Copyright © 2017 Richard Essemiah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ScheduleGames: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    
    var homeArrayLogo : [String] = []
    var homeArrayKey : [String] = []
    var awayArrayKey : [String] = []
    var awayTeamNames : [String] = []
    var homeTeamNames : [String] = []
    var gameID : [String] = []
    var goals : [String] = []
    var currentWeek: Int?
    
    @IBAction func gamesToHome(_ sender: AnyObject) {
        performSegue(withIdentifier: "games_home", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCurrentWeek()
        
    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.awayArrayKey.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScheduleGamesCell

        // Configure the cell...
        let rootRef = FIRDatabase.database().reference()
        
        if( awayArrayKey[indexPath.row] != "TEST") {
            cell.goalsLb.text = self.goals[indexPath.row]
            rootRef.child("soccer").child("teams").child(self.awayArrayKey[indexPath.row]).observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
            
                        let team = snapshot.value as? [String : AnyObject]
                        let awayTeamLogo = team?["logo"] as? String
                        let awayName = team?["teamName"] as? String
                        cell.awayTeamName.text = awayName!
                        cell.awayLogo.downloadImg(from: awayTeamLogo!)
                })
            
            rootRef.child("soccer").child("teams").child(self.homeArrayKey[indexPath.row]).observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
                
                let team = snapshot.value as? [String : AnyObject]
                let homeTeamLogo = team?["logo"] as? String
                let homeName = team?["teamName"] as? String
                cell.homeTeamNames.text = homeName!
                cell.homeLogo.downloadImg(from: homeTeamLogo!)
            })
        }
        return cell
    }
    
    func tableView(_ tableview: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: blogSegueIdentifier, sender: awayArrayKey[indexPath.row])
    }

    func getCurrentWeek() {
        
        var week: Int?
        let rootRef = FIRDatabase.database().reference()
        
        rootRef.child("soccer").child("currentWeek").observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
            week = snapshot.value! as? Int
            self.currentWeek = week!
            
            self.getGames()
        })
    }
    
    func getGames() {
        let rootRef = FIRDatabase.database().reference()
        rootRef.child("soccer").child("schedule").child("\(self.currentWeek!)").queryOrderedByKey().observe(FIRDataEventType.childAdded,   with: { snapshot in
            let games = snapshot.value as? [String : AnyObject]
            
            let awayKey = games?["awayteamkey"] as? String
            let homeKey = games?["hometeamkey"] as? String
            let awayGoals = games?["awayteamscore"] as? Int
            let homeGoals = games?["hometeamscore"] as? Int
            let gameid = games?["gameid"] as? Int
            if(homeGoals == 999){
                self.goals.append("-")
            }
            else {
                let goalScore = "\(homeGoals!) - \(awayGoals!)"
                self.goals.append(goalScore)
            }
            
            self.awayArrayKey.append(awayKey!)
            self.homeArrayKey.append(homeKey!)
            self.gameID.append(String(gameid!))
            self.tableview.reloadData()
        })

    }
    let blogSegueIdentifier = "gameStats"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == blogSegueIdentifier,
            let destination = segue.destination as? GameStatsViewController,
            let blogIndex = tableview.indexPathForSelectedRow?.row
        {
            destination.gameId =  gameID[blogIndex]
        }

    }
    
   }
