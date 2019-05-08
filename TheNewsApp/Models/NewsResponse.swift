//
//  Response.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 06/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
