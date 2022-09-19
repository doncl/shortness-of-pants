//
//  NFLFakeData.swift
//
//  Created by Don Clore on 2/4/21.

import Foundation
import UIKit

struct NFL {
    enum ConferenceType: Int {
        case afc = 0
        case nfc = 1
    }

    static let shared = NFL()

    private(set) var nfc: Conference!
    private(set) var afc: Conference!

    let nfcEastTeams: [Team] = [
        Team(name: "Dallas Cowboys", abbrev: "Dal"),
        Team(name: "New York Giants", abbrev: "NYG"),
        Team(name: "Philadelphia Eagles", abbrev: "Phi"),
        Team(name: "Washington Football Team", abbrev: "Wa"),
    ]

    let nfcNorthTeams = [
        Team(name: "Chicago Bears", abbrev: "Chi"),
        Team(name: "Detroit Lions", abbrev: "Det"),
        Team(name: "Green Bay Packers", abbrev: "GB"),
        Team(name: "Minnesota Vikings", abbrev: "Min"),
    ]

    let nfcSouthTeams: [Team] = [
        Team(name: "Atlanta Falcons", abbrev: "Atl"),
        Team(name: "Carolina Panthers", abbrev: "Car"),
        Team(name: "New Orleans Saints", abbrev: "NO"),
        Team(name: "Tampa Bay Buccaneers", abbrev: "TB"),
    ]

    let nfcWestTeams: [Team] = [
        Team(name: "Arizona Cardinals", abbrev: "Ari"),
        Team(name: "Los Angeles Rams", abbrev: "LAR"),
        Team(name: "San Francisco 49ers", abbrev: "SF"),
        Team(name: "Seattle Seahawks", abbrev: "Sea"),
    ]

    let afcEastTeams = [
        Team(name: "Buffalo Bills", abbrev: "Buf"),
        Team(name: "Miami Dolphins", abbrev: "Mia"),
        Team(name: "New England Patriots", abbrev: "NE"),
        Team(name: "New York Jets", abbrev: "NYJ"),
    ]
    let afcNorthTeams = [
        Team(name: "Baltimore Ravens", abbrev: "Bal"),
        Team(name: "Cincinnati Bengals", abbrev: "Cin"),
        Team(name: "Cleveland Browns", abbrev: "Cle"),
        Team(name: "Pittsburgh Steelers", abbrev: "Pit"),
    ]

    let afcSouthTeams = [
        Team(name: "Houston Texans", abbrev: "Hou"),
        Team(name: "Indianapolis Colts", abbrev: "Ind"),
        Team(name: "Jacksonville Jaguars", abbrev: "Jax"),
        Team(name: "Tennessee Titans", abbrev: "Ten"),
    ]

    let afcWestTeams = [
        Team(name: "Denver Broncos", abbrev: "Den"),
        Team(name: "Kansas City Chiefs", abbrev: "KC"),
        Team(name: "Las Vegas Raiders", abbrev: "LV"),
        Team(name: "Los Angeles Chargers", abbrev: "LAC"),
    ]

    private let nfcEast: Division!
    private let nfcNorth: Division!
    private let nfcSouth: Division!
    private let nfcWest: Division!

    private let afcEast: Division!
    private let afcNorth: Division!
    private let afcSouth: Division!
    private let afcWest: Division!

    private init() {
        nfcEast = Division(name: "East", teams: nfcEastTeams)
        nfcNorth = Division(name: "North", teams: nfcNorthTeams)
        nfcSouth = Division(name: "South", teams: nfcSouthTeams)
        nfcWest = Division(name: "West", teams: nfcWestTeams)

        afcEast = Division(name: "East", teams: afcEastTeams)
        afcNorth = Division(name: "North", teams: afcNorthTeams)
        afcSouth = Division(name: "South", teams: afcSouthTeams)
        afcWest = Division(name: "West", teams: afcWestTeams)

        nfc = Conference(name: "NFC Teams", east: nfcEast, north: nfcNorth, south: nfcSouth, west: nfcWest)
        afc = Conference(name: "AFC Teams", east: afcEast, north: afcNorth, south: afcSouth, west: afcWest)
    }
}

extension NFL {
    struct Conference {
        let name: String

        var east: Division
        var north: Division
        var south: Division
        var west: Division
    }

    struct Division {
        let name: String
        var teams: [Team]
    }

    struct Team {
        let name: String
        let abbrev: String
        let logo: UIImage

        init(name: String, abbrev: String) {
            self.name = name
            self.abbrev = abbrev
            logo = UIImage(named: abbrev)!
        }
    }
}
