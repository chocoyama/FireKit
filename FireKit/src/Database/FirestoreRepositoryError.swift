//
//  FirestoreRepositoryError.swift
//  FireKit
//
//  Created by Takuya Yokoyama on 2019/05/09.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation

public enum FirestoreRepositoryError: Error {
    case notFoundDocumentId
    case unknown(Error)
}
