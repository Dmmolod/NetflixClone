//
//  Movie.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import Foundation

struct ContentsResponse: Decodable {
    let page: Int
    let results: [Content]
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case page
        case results
    }
}

struct Content: Decodable {
    let backdropPath: String?
    let posterPath: String?
    let title: String?
    let id: Int
    let name: String?
    let overview: String?
    let mediaType: String?
    let voteCount: Int
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case mediaType = "media_type"
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case id
        case name
        case overview
        case title
    }
}

struct ContentImagesResponse: Decodable {
    let backdrops: [ContentImage]
}

struct ContentImage: Decodable {
    let filePath: String
    
    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }
}

struct TrendingMovieResponse: Decodable {
    
}

struct TrendingTvResponse: Decodable {
    
}

struct UpcomingMovieResponse: Decodable {
    
}

struct PopularResponse: Decodable {
    
}

struct TopRatedResponse: Decodable {
    
}
