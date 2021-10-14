//
//  NetworkingManager.swift
//  GitHub Viewer
//
//  Created by Marek Bartak on 12.10.2021.
//

import Foundation

protocol NetworkingManagerDelegate {
    
    func didUpdateRepositoryView (_ networkingManager: NetworkingManager ,_ allRepository: [RepositoryModel])
    func didFailWithError (_ errorSpot: String,_ error: Error)
}

struct NetworkingManager {
    
    
    var delegate: NetworkingManagerDelegate?
    
    func fetchData(searchText: String = "swift") {
        let githubSearchURL = "https://api.github.com/search/repositories?q=\(searchText)"
        performRequest(with: githubSearchURL)
    }
    
    func performRequest(with urlString: String) {
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    self.delegate?.didFailWithError("performRequest", error!)
                    return
                }
                
                if let safeData = data {
                    if let repositoryArray = self.parseJSON(safeData) {
                        self.delegate?.didUpdateRepositoryView(self, repositoryArray)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ repositoryData: Data) -> [RepositoryModel]? {
        let decoder = JSONDecoder()
        
        var repositoryArray = [RepositoryModel]()
        
        do {
            let decodedData = try decoder.decode(RepositoryData.self, from: repositoryData)
            
            decodedData.items.forEach { item in
                
                let name = item.full_name
                let description = item.description
                let url = item.html_url
                
                //Not all item have description, name and url is mandatory
                let repository = RepositoryModel(name: name, description: description ?? "", url: url)
                repositoryArray.append(repository)
            }
            return repositoryArray
            
        } catch {
            delegate?.didFailWithError("parseJSON", error)
            return nil
        }
    }
}
