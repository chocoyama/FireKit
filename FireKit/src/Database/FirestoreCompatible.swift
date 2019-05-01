//
//  FirestoreCompatible.swift
//  FireKit
//
//  Created by Takuya Yokoyama on 2019/02/24.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation

public protocol FirestoreCompatible {
    static var collectionName: String { get }
    var firestoreId: String? { get }
    init?(firestoreId: String, firestoreData: [String: Any])
    func toFirestoreData() -> [String: Any]
}
