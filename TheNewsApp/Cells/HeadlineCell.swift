//
//  HeadlineCell.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 06/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit
import SDWebImage

class HeadlineCell: UICollectionViewCell {

    //MARK: ELEMENTS
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sourceLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var article: Article? {
        didSet {
            titleLbl.text = article?.title
            sourceLbl.text = article?.source.name
            
            if let img = article?.urlToImage {
                imgView.sd_setImage(with: URL(string: img), completed: nil)
            }
        }
    }
    
    //MARK: CELL
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
    }

}
