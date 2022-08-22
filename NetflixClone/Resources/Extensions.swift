//
//  Extensions.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import Foundation
import UIKit

extension String {
    var uppercasedFirstLetter: String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

extension UICollectionViewCell {
    static var identifier: String { String(describing: self) }
}

extension UITableViewCell {
    static var identifier: String { String(describing: self) }
}
