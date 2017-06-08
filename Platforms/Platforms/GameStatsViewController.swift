//
//  GameStatsViewController.swift
//  Platforms
//
//  Created by Richard Essemiah on 06/05/2017.
//  Copyright © 2017 Richard Essemiah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire

class GameStatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var startersTableView: UITableView!
    @IBOutlet weak var benchTableView: UITableView!
    @IBOutlet weak var gameStatsTableView: UITableView!
    
    @IBOutlet weak var homeLogo: UIImageView!
    @IBOutlet weak var awayLogo: UIImageView!
    @IBOutlet weak var lineUpSwitch: UISegmentedControl!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var lineUpsView: UIView!
    @IBOutlet weak var mainSwitch: UISegmentedControl!
    
    
    var awayTeamName: String?
    var homeTeamName: String?
    var homeTeamLogo: String?
    var awayTeamStarters : [String] = []
    var homeTeamStarters : [String] = []
    var stats : [String] = []
    var starters : [String] = []
    var bench : [String] = []
    var awayTeamBench : [String] = []
    var homeTeamBench : [String] = []
    
    var gameId: String?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.mainSwitch.setTitle("Overview", forSegmentAt: 0)
        self.mainSwitch.setTitle("LineUps", forSegmentAt: 1)
        lineUpsView.isHidden = true
        statsView.isHidden = false
        
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
      
        self.getGameStats()
        startersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "startersCell")
        benchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "benchCell")
  

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(starters.count)
        if stats.count == 0 {
            startersTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            benchTableView.separatorStyle  = UITableViewCellSeparatorStyle.none
            gameStatsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            view.addSubview(activityIndicator)
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 3)
                
                OperationQueue.main.addOperation() {
                    self.startersTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.benchTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.gameStatsTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.activityIndicator.stopAnimating()
                    
                    self.starters = self.homeTeamStarters
                    self.bench = self.homeTeamBench
                
                    self.runTimedCode()
                }
            }

        }
    }
    
    func runTimedCode() {
        startersTableView.reloadData()
        benchTableView.reloadData()
        gameStatsTableView.reloadData()
        
    }
    @IBAction func mainSwitch(_ sender: UISegmentedControl) {
        switch mainSwitch.selectedSegmentIndex {
        case 0:
            statsView.isHidden = false
            lineUpsView.isHidden = true
        case 1:
            lineUpsView.isHidden = false
            statsView.isHidden = true
            
        default:
            break;
        }
        
    }
    
    @IBAction func lineupSwitch(_ sender: UISegmentedControl) {
        
        switch lineUpSwitch.selectedSegmentIndex
        {
        case 0:
            starters = homeTeamStarters
            bench = homeTeamBench
            runTimedCode()
        case 1:
            starters = awayTeamStarters
            bench = awayTeamBench
            runTimedCode()
        default:
            break; 
        }
    }
    
    
    
    
    
    let headers: HTTPHeaders = [
        "Ocp-Apim-Subscription-Key": "60607b037d334565be2700c93862405c",
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        if(tableView == self.startersTableView) {
            count = self.starters.count
        }
        
        if(tableView == self.benchTableView) {
            count = self.bench.count
        }
        if tableView == self.gameStatsTableView {
            count = self.stats.count
        }
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        if tableView == self.startersTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "startersCell", for: indexPath)
            cell?.textLabel?.text = self.starters[indexPath.row]
        
            
        }
        if tableView == self.benchTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "benchCell", for: indexPath)
            cell?.textLabel?.text = self.bench[indexPath.row]
            
            
        }
        
        if tableView == self.gameStatsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "gameStats", for: indexPath)
            let split = self.stats[indexPath.row].components(separatedBy: "-")
            
            cell?.imageView?.image = UIImage(named:"goal")
            cell?.textLabel?.text = "\(split.first!)' | \(split.last!)"
            for i in split {
                
                if i == "Home" {
                    cell?.textLabel?.textAlignment = .left
                    
                   
                }
                if i == "Away" {
                    cell?.textLabel?.textAlignment = .right
                  
                }
                
            }
        }
        
        return cell!
        
    }
    
    func getGameStats() {
        let rootRef = FIRDatabase.database().reference()
        let api_url = "https://api.fantasydata.net/soccer/v2/json/BoxScore/\(gameId!)"
        
        Alamofire.request(api_url, headers: headers).responseJSON { response in
            
            if let json = response.result.value {
                let results = json as! NSArray
                let gameStats = results[0] as? [String : AnyObject]
                let game = gameStats?["Game"] as? [String : AnyObject]
                let awayTeamKey = game?["AwayTeamKey"] as? String
                let homeTeamKey = game?["HomeTeamKey"] as? String
                let homeTeamId = game?["HomeTeamId"] as? Int
                let awayTeamId = game?["AwayTeamId"] as? Int
                // stats
                let goals = gameStats?["Goals"] as? NSArray
                for goal in goals! {
                    let goalState = goal as? [String : AnyObject]
                    let id = goalState?["TeamId"] as? Int
                    let name = goalState?["Name"] as? String
                    let minute = goalState?["GameMinute"] as? Int
                    
                    var type: String?
                    
                    if id == homeTeamId {
                        type = "Home"
                    }else {
                        type = "Away"
                    }
                    
                    var goalAdd: String?
                    
                    goalAdd = "\(minute!)-\(type!)-\(name!)"
                    self.stats.append(goalAdd!)
                    
                }
                // Linesup
                let lineups = gameStats?["Lineups"] as? NSArray
                for players in lineups! {
                    let player = players as? [String : AnyObject]
                    let playerName = player?["Name"] as? String
                    let playerTeamId = player?["TeamId"] as? Int
                    let playerType = player?["Type"] as? String
                    if(playerTeamId! == awayTeamId! && playerType! == "Starter") {
                        self.awayTeamStarters.append(playerName!)
                    }
                    if(playerTeamId! == homeTeamId! && playerType! == "Starter") {
                        self.homeTeamStarters.append(playerName!)
                    }
                    if(playerTeamId! == awayTeamId! && playerType! == "Bench") {
                        self.awayTeamBench.append(playerName!)
                    }
                    if(playerTeamId! == homeTeamId! && playerType! == "Bench") {
                        self.homeTeamBench.append(playerName!)
                    }
                }
                
                rootRef.child("soccer").child("teams").child(awayTeamKey!).observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
                    
                    let team = snapshot.value as? [String : AnyObject]
                    let teamName = team?["teamName"] as? String
                    let awayTeamLogo = team?["logo"] as? String
                    self.awayLogo.downloadImg(from: awayTeamLogo!)
                    self.lineUpSwitch.setTitle(teamName, forSegmentAt: 1)
                })
                
                rootRef.child("soccer").child("teams").child(homeTeamKey!).observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
                    
                    let team = snapshot.value as? [String : AnyObject]
                    let teamName = team?["teamName"] as? String
                    let homeTeamLogo = team?["logo"] as? String
                    self.homeLogo.downloadImg(from: homeTeamLogo!)
                    self.lineUpSwitch.setTitle(teamName, forSegmentAt: 0)
                })

                
            }
        }

    }
    
    
    
    


}
