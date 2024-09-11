//
//  UnsplashImage.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import Foundation

struct SearchResult: Decodable {
    let results: [UnsplashImage]
}

struct UnsplashImage: Decodable {
    let id: String
    let description: String?
    let urls: Urls
    let user: User
}

struct Urls: Decodable {
    let small: String
}

struct User: Decodable {
    let name: String
}
