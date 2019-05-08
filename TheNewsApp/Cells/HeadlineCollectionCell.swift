//
//  HeadlineCollectionCell.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 07/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit

class HeadlineCollectionCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    //MARK: VARIBALE
    var articles: [Article]?
    var delegate: HeadlineSelection?
    
    //MARK: ELEMENT
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: CELL
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubview(collectionView)
        addContraintWithFormat(format: "H:|[v0]|", views: collectionView)
        addContraintWithFormat(format: "V:|[v0]|", views: collectionView)
        collectionView.register(UINib(nibName: "HeadlineCell", bundle: nil), forCellWithReuseIdentifier: "HeadlineCell")
    }
    
    
    //MARK: COLLECTION VIEW
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = articles?.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadlineCell", for: indexPath) as? HeadlineCell {
            
            guard let article = articles?[indexPath.row] else { return cell }
            cell.article = article
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aspect: CGFloat = 16/9
        let width = (frame.width/3) * aspect
        
        return CGSize(width: width, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? HeadlineCell {
            delegate?.cellSelected(article: cell.article!)
        }
    }
    
}
