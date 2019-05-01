//
//  FirestoreQueryBuilder.swift
//  FireKit
//
//  Created by Takuya Yokoyama on 2019/05/01.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import FirebaseFirestore

public enum SearchQuery {
    case equal(field: String, value: Any) // ==
    case lessThan(field: String, value: Any) // <
    case lessThanOrEqualTo(field: String, value: Any) // <=
    case greaterThan(field: String, value: Any) // >
    case greaterThanOrEqualTo(field: String, value: Any) // >=
}

class FirestoreQueryBuilder {
    static func build(for collectionRef: CollectionReference, by searchQuery: [SearchQuery]?) -> Query {
        let ref = collectionRef
        
        let query = searchQuery?.enumerated().reduce(ref) { (query: Query, value: (offset: Int, element: SearchQuery)) -> Query in
            let queryTarget: Query = value.offset == 0 ? ref : query
            switch value.element {
            case .equal(let field, let value):
                return queryTarget.whereField(field, isEqualTo: value)
            case .lessThan(let field, let value):
                return queryTarget.whereField(field, isLessThan: value)
            case .lessThanOrEqualTo(let field, let value):
                return queryTarget.whereField(field, isLessThanOrEqualTo: value)
            case .greaterThan(let field, let value):
                return queryTarget.whereField(field, isGreaterThan: value)
            case .greaterThanOrEqualTo(let field, let value):
                return queryTarget.whereField(field, isGreaterThanOrEqualTo: value)
            }
        }
        
        return query ?? ref
    }
}
