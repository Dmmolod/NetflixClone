//
//  APICaller.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import Foundation

class APICaller {
    
    enum APIError: String, Error {
        case failedToGetData
        case failedToGetURL
        case failedToParseData
        case failedToGetQuery
    }
    
    private struct Constants {
        static let apiKey = "6b17d488280ac0859560482490d1f60d"
        static let baseURL = "https://api.themoviedb.org"
        static let youTubeAPIKey = "AIzaSyCcyJEEzLUox6yZKckP9DNg2bqBupT7aMk"
        static let youTubeBaseURL = "https://youtube.googleapis.com/youtube/v3/search?"
    }
    
    
    
    func get(for type: HomeSectionType, completion: @escaping (Result<[Content], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/\(type.urlPath)?api_key=\(Constants.apiKey)") else {
            DispatchQueue.main.async { completion(.failure(APIError.failedToGetURL)) }
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { DispatchQueue.main.async { completion(.failure(APIError.failedToGetData)) }; return }
            guard let contentsResponse = try? JSONDecoder().decode(ContentsResponse.self, from: data) else {
                DispatchQueue.main.async { completion(.failure(APIError.failedToParseData)) }
                return
            }
            DispatchQueue.main.async { completion(.success(contentsResponse.results)) }
        }
        task.resume()
    }
    
    func getDiscoverMovies(completion: @escaping (Result<[Content], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/discover/movie?api_key=\(Constants.apiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate") else {
            completion(.failure(APIError.failedToGetURL))
            return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let contentsResponse = try? JSONDecoder().decode(ContentsResponse.self, from: data) else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            DispatchQueue.main.async { completion(.success(contentsResponse.results)) }
        }.resume()
    }
    
    func search(with query: String, completion: @escaping (Result<[Content], Error>) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(.failure(APIError.failedToGetQuery))
            return
        }
    
        guard let url = URL(string: "\(Constants.baseURL)/3/search/movie?api_key=\(Constants.apiKey)&query=\(query)") else {
            completion(.failure(APIError.failedToGetURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let contentsResponse = try? JSONDecoder().decode(ContentsResponse.self, from: data) else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            DispatchQueue.main.async { completion(.success(contentsResponse.results)) }
        }.resume()
    }
    
    func getMovie(with query: String, completion: @escaping (Result<VideoElement, Error>) -> Void) {
        
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL(string: "\(Constants.youTubeBaseURL)q=\(query)&key=\(Constants.youTubeAPIKey)") else { return }
        
        
        print(url)
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            guard let result = try? JSONDecoder().decode(YoutubeSearchResponse.self, from: data) else {
                completion(.failure(APIError.failedToParseData))
                return
            }
            let filteredResult = result.items.filter { $0.id.videoId != nil }

            DispatchQueue.main.async { completion(.success(filteredResult[0])) }
        }.resume()
    }
}
