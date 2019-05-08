//
//  Protocals.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 07/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import Foundation

protocol CategoryMenuBtn: class {
    func categorySelected(category: String)
    func countrySelected(country: String)
}

protocol HeadlineSelection: class {
    func cellSelected(article: Article)
}
