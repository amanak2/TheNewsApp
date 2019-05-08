//
//  CategoryMenuCell.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 07/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit

class CategoryMenuCell: BaseCollectionCell {
    
    override var isSelected: Bool {
        didSet {
            hightlightView.backgroundColor = isSelected ? Theme.darkTintColor : Theme.tintColor
        }
    }
    
    //MARK: ELEMENTS
    let hightlightView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        return view
    }()
    
    let titleLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = Theme.whiteColor
        return label
    }()
    
    //MARK: Cell
    override func setupCell() {
        super.setupCell()        
        addSubview(hightlightView)
        hightlightView.addSubview(titleLbl)
        
        addContraintWithFormat(format: "H:|-5-[v0]-5-|", views: hightlightView)
        addContraintWithFormat(format: "V:[v0(40)]", views: hightlightView)
        
        hightlightView.addContraintWithFormat(format: "H:|[v0]|", views: titleLbl)
        hightlightView.addContraintWithFormat(format: "V:|[v0]|", views: titleLbl)
    }
    
}
