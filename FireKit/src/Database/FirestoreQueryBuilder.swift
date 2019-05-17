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

public enum Order {
    case descendingBy(field: String)
    case ascendingBy(field: String)
}

class FirestoreQueryBuilder {
    static func build(for collectionRef: CollectionReference,
                      by searchQuery: [SearchQuery]?,
                      order: Order?) -> Query {
        let ref = collectionRef
        
        var query = searchQuery?.enumerated().reduce(ref) { (query: Query, value: (offset: Int, element: SearchQuery)) -> Query in
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
        
        if let order = order {
            switch order {
            case .ascendingBy(let field):
                query = query?.order(by: field, descending: false)
            case .descendingBy(let field):
                query = query?.order(by: field, descending: true)
            }
        }
        
        return query ?? ref
    }
}
