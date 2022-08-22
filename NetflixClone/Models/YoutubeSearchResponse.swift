//
//  YoutubeSearchResponse.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 22.08.2022.
//

import Foundation


struct YoutubeSearchResponse: Decodable {
    let items: [VideoElement]
}

struct VideoElement: Decodable {
    let id: IdVideoElement
}

struct IdVideoElement: Decodable {
    let videoId: String?
}

