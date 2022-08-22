//
//  ImageManager.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import Foundation
import UIKit

struct ImageManager {
    
    private let path: String?
    private let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first
    
    init(_ path: String?) {
        self.path = path
    }
        
    func fetch(completion: @escaping (UIImage?) -> Void) {
        guard let path = path,
              let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)"),
              let cacheDirectory = cacheDirectory else { return }
        
        if let dataFromCache = FileManager.default.contents(atPath: cacheDirectory.appendingPathComponent(path).path),
           let imageFromData = UIImage(data: dataFromCache) {
            completion(imageFromData)
            debugPrint("Image From CACHE")
        }
        else {
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil,
                      let downloadingImage = UIImage(data: data) else { return }
                
                let downloadingImageData = downloadingImage.pngData()
                FileManager.default.createFile(atPath: cacheDirectory.appendingPathComponent(path).path,
                                               contents: downloadingImageData, attributes: nil)
                
                completion(downloadingImage)
                debugPrint("Image From INTERNET")
            }.resume()
        }
    }
}
