//
//  ContentPreviewViewModel.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 22.08.2022.
//

import Foundation
import UIKit

struct ContentPreviewViewModel {
    let title: String?
    let youtubeView: VideoElement?
    let posterPath: String?
    let contentOverview: String?
    let images: [ContentImage]?
}
