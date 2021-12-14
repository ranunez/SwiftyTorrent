//
//  IMDBDataProvider.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 30.06.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import Combine

extension String: Error { }

final class IMDBDataProvider {
    private let urlSession: URLSession = URLSession.shared
    private let endpointURL = URL(string: "https://sg.media-imdb.com/")!
    
    private var cache = [String: String]()
    
    func fetchSuggestions(_ query: String) -> AnyPublisher<String, Error> {
        let query = query.lowercased()
        // Cache look-up
        if let imdbId = cache[query] {
            return Just(imdbId)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        // Constructs path like: `suggests/s/simpsons.json`
        let requestURL = endpointURL.appendingPathComponent("suggests/\(query.prefix(1))/\(query).json")
        return urlSession
            .dataTaskPublisher(for: requestURL)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                          throw URLError(.badServerResponse)
                      }
                return data
            }
            .tryMap { (data) -> Data in
                // Strip json-p padding `imdb$search_query()`
                var value = String(bytes: data, encoding: .utf8)!
                if let idx = value.firstIndex(of: "(") {
                    value.removeSubrange(value.startIndex..<idx)
                    value = String(value.dropFirst())
                    value = String(value.dropLast())
                }
                return value.data(using: .utf8)!
            }
            .decode(type: Response.self, decoder: JSONDecoder())
            .tryMap { imdbResponse -> String in
                guard var imdbId = imdbResponse.data.first?.id else {
                    throw "IMDB show not found."
                }
                imdbId = String(imdbId.dropFirst(2)) // remove "tt"
                return imdbId
            }
            .handleEvents(receiveOutput: { imdbId in
                // Cache `imdbId`
                self.cache[query] = imdbId
            })
            .eraseToAnyPublisher()
    }
    
}

extension IMDBDataProvider {
    struct Response: Decodable {
        enum CodingKeys: String, CodingKey {
            case data = "d"
        }
        
        let data: [DataItem]
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            data = try values.decode([DataItem].self, forKey: .data)
        }
        
        struct DataItem: Decodable {
            let id: String
        }
        
    }
    
}
