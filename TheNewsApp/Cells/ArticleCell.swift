//
//  ArticleCell.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 06/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit
import SDWebImage

class ArticleCell: UITableViewCell {

    //MARK: ELEMENTS
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var sourceLbl: UILabel!
    @IBOutlet weak var timeAgoLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    //MARK: VARIABLES
    var article: Article? {
        didSet {            
            titleLbl.text = article?.title
            sourceLbl.text = article!.source.name
            
            if let time = article?.publishedAt {
                timeAgoLbl.text = UserUtil.timeAgoSinceDate(fromStringUTC: time)
            }

            if let img = article?.urlToImage {
                imgView.sd_setImage(with: URL(string: img), completed: nil)
            }
        }
    }
    
    //MARK: CELL
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 5
        imgView.clipsToBounds = true
    }
    
}
