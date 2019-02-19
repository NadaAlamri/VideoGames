//
//  TableCell.swift
//  VideoGames
//
//  Created by Nada AlAmri on 07/06/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import Foundation
import UIKit
class TableCell: UITableViewCell
{
    @IBOutlet weak var GameImage: UIImageView!
    @IBOutlet weak var imageTitle: UILabel!
   // @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var details: UILabel!
}
