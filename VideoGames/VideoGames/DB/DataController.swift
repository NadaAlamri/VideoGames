//
//  DataController.swift
//  VideoGames
//
//  Created by Nada AlAmri on 11/06/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import Foundation
import  CoreData
class DataController
{
    
    let persisintentContaoner: NSPersistentContainer
    
    var viewContext : NSManagedObjectContext{
        return persisintentContaoner.viewContext
    }
    init(modelName:String) {
        persisintentContaoner = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()-> Void)? = nil){
        
        persisintentContaoner.loadPersistentStores{ storeDescription , error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
