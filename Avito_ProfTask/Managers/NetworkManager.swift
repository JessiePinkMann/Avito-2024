//
//  NetworkManager.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

class NetworkManager {
    static let shared = NetworkManager()

    private let baseURL = "https://api.unsplash.com/search/photos"
    private let accessKey = "Mo1EuSZ2I4Ek0-zfkyjTCYfxtU5N8L0j_qF3ZuCrIr0"

    private init() {}

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        return URLSession(configuration: config)
    }()

    func searchImages(query: String, page: Int = 1, sortBy: String = "relevant", completion: @escaping (Result<[UnsplashImage], NetworkError>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "order_by", value: sortBy),
            URLQueryItem(name: "client_id", value: accessKey)
        ]

        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed))
                print("Request failed with error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion(.failure(.requestFailed))
                print("No data received from server")
                return
            }

            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(result.results))
            } catch {
                completion(.failure(.decodingFailed))
                print("Decoding failed with error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
