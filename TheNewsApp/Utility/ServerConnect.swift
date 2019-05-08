//
//  ServerConnect.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 06/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import Foundation

class ServerConnect {
    
    let session = URLSession.shared
    
    enum Result<String> {
        case successBlock
        case failureBlock(String)
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299: return .successBlock
        case 401...500: return .failureBlock("Auth Error")
        case 501...599: return .failureBlock("Bad Request")
        case 600: return .failureBlock("Outdated")
        default: return .failureBlock("FAIL")
        }
    }
    
    func getArticles(fromUrl url: URL, completion: @escaping (_ data: Data?, _ error: String?) -> ()) {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .successBlock:
                    guard let data = data else { return }
                    completion(data,nil)
                case .failureBlock(let networkError):
                    completion(nil, networkError)
                }
                
            }
            
        }.resume()
    }
    
}
