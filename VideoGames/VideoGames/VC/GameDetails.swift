//
//  ViewController.swift
//  VideoGames
//
//  Created by Nada AlAmri on 07/06/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import UIKit
import  CoreData
class GameDetails: UIViewController {
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var gameInfo: UILabel!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
 
     var dataController : DataController!
    var gameID : Int?
    var videoGame : VideoGame?
    var gameList2 = [Game]()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    override func viewDidLoad() {
        super.viewDidLoad()
  
        if(!getDataFromDB())
        {
            
        
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            getIgdbGames()
            
        }
        
        

    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
       
        // Do any additional setup after loading the view, typically from a nib.
       activityIndicator.startAnimating()
  
        
    }
 
    func getDataFromDB()->Bool
    {
        let fetchRequest : NSFetchRequest<VideoGame> = VideoGame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@",String(gameID!))
        if let result = try?  dataController.viewContext.fetch(fetchRequest)
        {
            if(result.count>0)
            {
                for i in 0...result.count-1
                {
                    gameTitle.text = result[i].name
                    let rating = result[i].rating ?? "0.0"
                    
                    gameInfo.text = "Genre:\(result[i].game_genre ?? "")\n Rating:\(rating)"
                    
                    summary.text = result[i].summary
                   gameImage.image = UIImage(data: result[i].photo as! Data)
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()}
                return true
            }
            
        }
        return false
    }
    func getIgdbGames()
    { //activityIndicator.startAnimating()
        
        print("IDD")
        print(gameID)
        IgdbApi.GameDetails(num: gameID!){(gamesList, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.showAlert("Error", message: "Error performing your request: \(error?.localizedDescription ?? "")")
                    return
                }
                guard var gamesArray = gamesList else {
                    self.showAlert( "Error loading Games", message: "There was an error loading games")
                    return
                }
                //get gamecover & genre
                for i in 0...gamesArray.count-1 {
                    if(gamesArray[i].cover != nil)
                    {
                        IgdbApi.getCoverUrl(id: gamesArray[i].cover!) {(coverUrl, error) in
                            if error != nil {
                                //load default
                                return
                            }
                            guard let coverUrl = coverUrl else {
                                //  self.showAlert( "Error loading Games", message: "There was an error loading games")
                                return
                            }
                            //  print(coverUrl)
                            gamesArray[i].coverUrl = coverUrl
                            DispatchQueue.main.async {
                            self.gameImage.image = try! UIImage(data: Data(contentsOf: URL (string:coverUrl)!))
                            self.summary.text = gamesArray[i].summary
                                self.gameTitle.text =  gamesArray[i].name
                            }
                            if(gamesArray[i].genres != nil)
                            {
                                var genreList = ""
                                for j in 0...(gamesArray[i].genres?.count)!-1 {
                                    if(j == 0)
                                    {
                                        genreList =  String(gamesArray[i].genres![j])
                                    }
                                    else
                                    {
                                        genreList = "\(genreList),\(gamesArray[i].genres![j])"
                                    }
                                }
                               IgdbApi.getGenres(genres: genreList) {(gameGenre, error) in
                                    if error != nil {   //load default
                                        return
                                    }
                                    guard let gameGenre = gameGenre else {
                                        //  self.showAlert( "Error loading Games", message: "There was an error loading games")
                                        gamesArray[i].game_genre = "not specified"
                                        return
                                    }
                                
                                  gamesArray[i].game_genre = gameGenre
                                do
                                {
                                    let vg = VideoGame(context: self.dataController.viewContext)
                                    vg.id = "\(gamesArray[i].id ?? 0)"
                                    vg.name = gamesArray[i].name
                                    if gamesArray[i].aggregated_rating != nil
                                    {
                                        vg.aggregated_rating = gamesArray[i].aggregated_rating!
                                    }
                                    
                                    vg.url = gamesArray[i].url
                                    vg.coverUrl = gamesArray[i].coverUrl
                                    vg.summary = gamesArray[i].summary
                                    vg.storyline = gamesArray[i].storyline
                                    vg.rating = "\(gamesArray[i].rating ?? 0)"
                                    vg.coverID = "\(gamesArray[i].cover ?? 0)"
                                    vg.game_genre = gamesArray[i].game_genre
                                    if(gamesArray[i].coverUrl != nil)
                                    {
                                        
                                        // String.self imgUrl = self.gameList2[indexPath.item].coverUrl
                                        if(gamesArray[i].coverUrl != nil)
                                        {
                                            let downloadImage = try! UIImage(data: Data(contentsOf: URL (string:gamesArray[i].coverUrl!)!))
                                            vg.photo =  UIImagePNGRepresentation(downloadImage!) as Data?
                                        }
                                        
                                    }
                                    
                                    try self.dataController.viewContext.save()
                                    //   print("done:  \(gamesArray[i].name)")
                                }
                                catch let error
                                {
                                    print(error)
                                }
                                
                                    var rating:String = String(format: "%.1f", gamesArray[i].rating ?? 0.0)
                                    DispatchQueue.main.async {
                                        self.gameInfo.text =  "Genre:\(gameGenre)\n Rating:\(rating)"
                                     self.activityIndicator.stopAnimating()
                                        self.activityIndicator.removeFromSuperview()
                                    }
                                  
                                }}//gamesArray
                        }//coverurl
                    }
                    
                    
                }
            }
        }
        
      
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
            return
        }))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
}

