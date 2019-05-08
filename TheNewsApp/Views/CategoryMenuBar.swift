//
//  CategoryMenuBar.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 07/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit

class CategoryMenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: ELEMENTS
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Theme.tintColor
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    //MARK: VARIABLES
    let categories = ["General", "Business", "Entertainment", "Health", "Science", "Sports", "Technology"]
    var delegate: CategoryMenuBtn?
    
    //MARK: VIEW
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        let selectedCell = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedCell, animated: false, scrollPosition: .left)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    
    func setupView() {
        collectionView.register(CategoryMenuCell.self, forCellWithReuseIdentifier: "Cell")
        addSubview(collectionView)
        
        addContraintWithFormat(format: "H:|[v0]|", views: collectionView)
        addContraintWithFormat(format: "V:|[v0]|", views: collectionView)
    }
    
    //MARK: COLLECTION VIEW
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CategoryMenuCell {
            
            cell.titleLbl.text = categories[indexPath.row]
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        
        let title = categories[indexPath.row]
        let estimatedFrame = NSString(string: title).boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return CGSize(width: estimatedFrame.width + 34, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryMenuCell {
            if cell.isSelected {
                self.delegate?.categorySelected(category: cell.titleLbl.text!)
            }
        }
    }
}
