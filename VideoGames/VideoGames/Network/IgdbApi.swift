//
//  IgdbApi.swift
//  VideoGames
//
//  Created by Nada AlAmri on 07/06/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import Foundation
import UIKit
class IgdbApi
{
    
    static func getGenres(genres : String, completion: @escaping ( String?, Error?)->()) {
        
        var request = URLRequest (url: URL (string: "https://api-v3.igdb.com/genres/\(genres)?fields=*")!)
            //?fields=*&filter[id][eq]=\(genres)")!)
        ///
        request.addValue("abda7e613adabf5f82d23fa57fb65780", forHTTPHeaderField: "user-key")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request){data, response, error in
            if error != nil {
                completion("", error)
                return
                
            }
            
            //   print (String(data: data!, encoding: .utf8)!)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                
                let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion("", statusCodeError)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                guard let dataResponse = data else {return }
                do
                {
                    let decoder = JSONDecoder()
                    let genres = try decoder.decode([Genre].self, from: dataResponse) //Decode JSON Response Data
                    var allGenre = ""
                    for i in 0...genres.count-1
                    {
                        if(i==0)
                        {
                            allGenre = genres[i].name!
                        }
                        else
                        {
                            allGenre = "\(allGenre), \(genres[i].name!)"
                        }
                        
                    }
                    //  print("ggg")
               //     print(genres)
                    completion(allGenre, nil)
                } catch let parsingError {
                    print(parsingError)
                }
                
                
                
            }
        }
        
        task.resume()
        
    }
    
 
    
    static func GameDetails(num: Int, completion: @escaping ([Game]?, Error?) -> ())
    {
        var request :URLRequest
        if(num == 1)
        {
         request = URLRequest (url: URL (string: "https://api-v3.igdb.com/games?fields=*&filter[platforms][eq]=48&filter[rating][gt]=70&limit=20&order=popularity:desc")!)
        }
        else
        {
               request = URLRequest (url: URL (string: "https://api-v3.igdb.com/games/\(num)?fields=*")!)
        }
        ///
        request.addValue("abda7e613adabf5f82d23fa57fb65780", forHTTPHeaderField: "user-key")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request){data, response, error in
            if error != nil {
                completion(nil, error)
                return
                
            }
          //  print (String(data: data!, encoding: .utf8)!)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion(nil , statusCodeError)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                // let jsonResponse = try! JSONSerialization.jsonObject(with: data!, options: [])
                //     guard let jsonArray = jsonResponse as? [[String: Any]] else {
                //      return
                //   }
                guard let dataResponse = data else {return }
                do
                {
                    let decoder = JSONDecoder()
                    var games = try decoder.decode([Game].self, from: dataResponse) //Decode JSON Response Data
        
                    completion(games, nil)
                    return
                } catch let parsingError {
                    print(parsingError)
                }
            }
        }
        
        task.resume()
    }
    
    static func getCoverUrl(id : Int, completion: @escaping ( String?, Error?)->()) {
        var request = URLRequest (url: URL (string: "https://api-v3.igdb.com/covers?fields=*&filter[id][eq]=\(id)")!)
        //   var request = URLRequest (url: URL (string: "https://api-v3.igdb.com/covers?image_id=\(id)&fields=*")!)
        ///
        request.addValue("abda7e613adabf5f82d23fa57fb65780", forHTTPHeaderField: "user-key")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request){data, response, error in
            if error != nil {
                completion("", error)
                return //error?.localizedDescription
                
            }
            //  print (String(data: data!, encoding: .utf8)!)
            guard let dataResponse = data else {return }
            
            do
            {
                //  print(dataResponse)
                let decoder = JSONDecoder()
                var cover2 = try decoder.decode([cover].self, from: dataResponse) //Decode JSON Response Data
              //  print("xx")
               // print(cover2.count)
             //   for i in 0...cover2.count-1
                //{
                 
                    if let cover1 = cover2[0].url
                    {
                        completion( "https:\(cover1)", nil)
                    }
              //  }
                
            }
            catch let parsingError {
                completion("", parsingError)
                
            }
        }
        task.resume()
        
        
    }
    
    
}
