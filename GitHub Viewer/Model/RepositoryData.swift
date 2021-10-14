//
//  RepositoryData.swift
//  GitHub Viewer
//
//  Created by Marek Bartak on 12.10.2021.
//

import Foundation

struct  RepositoryData: Decodable {
    let items: [Item]
}

struct Item: Decodable {
    let full_name: String
    let description: String?
    let html_url: String
}
