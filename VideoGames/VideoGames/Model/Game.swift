//
//  Game.swift
//  VideoGames
//
//  Created by Nada AlAmri on 07/06/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import Foundation
import UIKit
struct Game: Codable {
    var id: Int?
    var name: String?
    var aggregated_rating: Double?
    var url: String?
    var coverUrl: String?
    var summary: String?
    var storyline : String?
    var rating : Double?
    var cover : Int?
    var genres: [Int]?
    var game_genre: String?
  //  var game_engines : [game_engines]
}

struct GameCore {
    var id: Int?
    var name: String?
    var aggregated_rating: Double?
    var url: String?
    var coverUrl: String?
    var summary: String?
    var storyline : String?
    var rating : String?
    var cover : Int?
    var genres: [Int]?
    var game_genre: String?
    var image : UIImage?
    //  var game_engines : [game_engines]
}
struct Genre : Decodable{
    var name: String?
    var id: Int?
}
struct game_engines: Codable
{
    var platforms: [Int]?
}

struct Platforms: Codable {
    var id :Int
 //   var name: String
}

struct cover:Codable {
    var image_id: String?
    var url: String?
}
