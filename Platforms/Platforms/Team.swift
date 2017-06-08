//
//  Team.swift
//  Platforms
//
//  Created by Richard Essemiah on 20/04/2017.
//  Copyright © 2017 Richard Essemiah. All rights reserved.
//

import Foundation

class Team {
    var teamid: Int?
    var key: String?
    var name: String?
    var logo: String?
    
    init(teamid: Int, key: String, name: String, logo:String) {
        self.teamid = teamid
        self.key = key
        self.name = name
        self.logo = logo
    }
}
