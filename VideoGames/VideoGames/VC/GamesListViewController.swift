//
//  GamesListViewController.swift
//  VideoGames
//
//  Created by Nada AlAmri on 07/06/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import UIKit
import CoreData

class GamesListViewController: UITableViewController {
    
    //array
    
    
    var dataController : DataController!
    var gameList2 = [GameCore]()
    var videoG: VideoGame?
    var gamesCount : Int = 0
    
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    override func viewDidLoad() {
        super.viewDidLoad()
           activityIndicator.startAnimating()
       
        getDataFromDB()
        if(gameList2.count>0)
        {
         
            tableView.reloadData()
           
        }
        else
        {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            getIgdbGames()
      
        }
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.addSubview(activityIndicator)
        activityIndicator.frame = tableView.bounds
        
        // Do any additional setup after loading the view, typically from a nib.
    
  
    }
    
    @IBAction func Refresh(_ sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        gameList2 = [GameCore]()
        tableView.reloadData()
        getIgdbGames()
        activityIndicator.stopAnimating()
    }
    func getIgdbGames()
    {
        IgdbApi.GameDetails(num: 1){(gamesList, error) in
            DispatchQueue.main.async {
                
                if error != nil {
                    
                    self.showAlert("Error", message: "Error performing your request: \(error?.localizedDescription ?? "")")
                    //calling data from DB
                        DispatchQueue.main.async {
                    self.getDataFromDB()
                            if(self.gameList2.count>0)
                            {
                                
                                self.tableView.reloadData()
                                
                            }
                    }
                    return
                }
                guard var gamesArray = gamesList else {
                    self.showAlert( "Error loading Games", message: "There was an error loading games")
                    return
                }
                 var x = GameCore()
                //get gamecover & genre
                for i in 0...gamesArray.count-1 {
                       self.gameList2.append(x)
                    //cover
                    if(gamesArray[i].cover != nil)
                    {
                        // print(gamesArray[i].cover)
                        IgdbApi.getCoverUrl(id: gamesArray[i].cover!) {(coverUrl, error) in
                            //  DispatchQueue.main.async {
                            
                            if error != nil {
                                //load default
                                return
                            }
                            guard let coverUrl = coverUrl else {
                                //  self.showAlert( "Error loading Games", message: "There was an error loading games")
                                return
                            }
                            
                            gamesArray[i].coverUrl = coverUrl
                        
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
                                    // DispatchQueue.main.async {
                                    
                                    if error != nil {
                                        //load default
                                        self.showAlert( "Error loading Genre", message: "There was an error loading games")
                                        return
                                    }
                                    guard let gameGenre = gameGenre else {
                                        //  self.showAlert( "Error loading Games", message: "There was an error loading games")
                                        gamesArray[i].game_genre = "not specified"
                                        return
                                    }
                                    
                                    gamesArray[i].game_genre = gameGenre
                                  //  self.gameList2.append(gamesArray[i])
                                    
                                   
                                 
                                    self.gameList2[i].name = gamesArray[i].name
                                    self.gameList2[i].game_genre = gamesArray[i].game_genre
                                    self.gameList2[i].coverUrl = gamesArray[i].coverUrl
                                    self.gameList2[i].id = Int(gamesArray[i].id!)
                                    if(gamesArray[i].coverUrl != nil)
                                    {
                                        let downloadImage = try! UIImage(data: Data(contentsOf: URL (string:gamesArray[i].coverUrl!)!))
                                       self.gameList2[i].image =  downloadImage
                                    }
                                   
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.tableView.reloadData()
                                        self.activityIndicator.stopAnimating()
                                        self.activityIndicator.removeFromSuperview()
                                        
                                        if( self.checkGame(id: gamesArray[i].id!))
                                        {
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
                                        }
                                        
                                        
                                    }
                                }
                                //
                            }
                        }
                    }
                }
                
                
            }
        }
        
        
    }
    
    
    func checkGame(id: Int)-> Bool
    {
        let fetchRequest : NSFetchRequest<VideoGame> = VideoGame.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@","\(id)")
        if let result = try?  dataController.viewContext.fetch(fetchRequest)
        {
            if(result.count > 0)
            {
                
                return false
            }
            else
            {
                return true
            }
        }
        return true
    }
    func getDataFromDB()
    {
        let fetchRequest : NSFetchRequest<VideoGame> = VideoGame.fetchRequest()
        if let result = try?  dataController.viewContext.fetch(fetchRequest)
        {
            var x = GameCore()
            if(result.count>0)
            {
                for i in 0...result.count-1
                {
                    gameList2.append(x)
                    gameList2[i].name = result[i].name
                    gameList2[i].game_genre = result[i].game_genre
                    gameList2[i].coverUrl = result[i].coverUrl
                    gameList2[i].id = Int(result[i].id!)
                    gameList2[i].image = UIImage(data: result[i].photo as! Data)
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
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return gameList2.count
    }
    
    //populate the cell
    override func tableView(_ tableView: UITableView,  cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        //obtain a cell of type Table Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.015)
        cell.indicator.color = .gray
      
        DispatchQueue.main.async {
             
            if self.gameList2.count >= indexPath.item + 1 {
                // Display photo
                if(self.gameList2[indexPath.item].coverUrl != nil)
                {
                    cell.GameImage.image = self.gameList2[indexPath.item].image
                    
                }
                else
                {
                    cell.GameImage.image = UIImage(named: "ps4")
                }
                cell.imageTitle.text = self.gameList2[indexPath.item].name
                cell.details.text = self.gameList2[indexPath.item].game_genre
            }
                
            else
            {
                cell.imageTitle.text = "nothing "
                
            }
        }
        
     //   cell.indicator.stopAnimating()
      //  cell.indicator.removeFromSuperview()
        return cell
    }
    
    //push the detail view controller when the meme is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "GameDetails") as! GameDetails
        controller.gameID = self.gameList2[(indexPath as NSIndexPath).row].id
        controller.dataController = self.dataController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    func Del()
    {
        let fetchRequest : NSFetchRequest<VideoGame> = VideoGame.fetchRequest()
        //  fetchRequest.predicate = NSPredicate(format: "id == %@","\(id)")
        if let result = try?  dataController.viewContext.fetch(fetchRequest)
        {
            if(result.count > 0)
            {
                
                for object in result {
                    do{
                        dataController.viewContext.delete(object)
                        try dataController.viewContext.save()
                        print("done")
                    }
                    catch let error
                    {
                        print(error)
                    }
                    
                }
               
            }
            else
            {
                
            }
        }
    }
    
    
}
