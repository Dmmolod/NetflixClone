//
//  DataPersistenseManager.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 22.08.2022.
//

import Foundation
import UIKit
import CoreData

class DataPersistenseManager {
    
    enum DataBaseError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    
    static let shared = DataPersistenseManager()
    
    func downloadContent(with model: Content, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let item = ContentItem(context: context)
        
        item.id = Int64(model.id)
        item.title = model.title
        item.name = model.name
        item.overview = model.overview
        item.posterPath = model.posterPath
        item.backdropPath = model.backdropPath
        item.voteCount = Int64(model.voteCount)
        item.voteAverage = model.voteAverage
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DataBaseError.failedToSaveData))
        }
    }
    
    func fetchingContentFromDataBase(_ completion: @escaping (Result<[ContentItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<ContentItem>
        request = ContentItem.fetchRequest()
        
        do {
            let contents = try context.fetch(request)
            completion(.success(contents))
        } catch {
            completion(.failure(DataBaseError.failedToFetchData))
        }
    }
    
    func deleteContent(with model: ContentItem, _ completion: @escaping (Result<Void,Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DataBaseError.failedToDeleteData))
        }
    }
}
