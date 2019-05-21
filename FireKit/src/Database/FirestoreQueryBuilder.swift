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

public enum Order: Equatable {
    case descendingBy(field: String)
    case ascendingBy(field: String)
}

class FirestoreQueryBuilder {
    static func build(for collectionRef: CollectionReference,
                      by searchQuery: [SearchQuery]?,
                      orders: [Order]?) -> Query {
        var orders = orders ?? []
        let ref = collectionRef
        
        var query = searchQuery?.enumerated().reduce(ref) { (query: Query, value: (offset: Int, element: SearchQuery)) -> Query in
            var queryTarget: Query = value.offset == 0 ? ref : query
            let orderField: String
            
            switch value.element {
            case .equal(let field, let value):
                queryTarget = queryTarget.whereField(field, isEqualTo: value)
                orderField = field
            case .lessThan(let field, let value):
                queryTarget = queryTarget.whereField(field, isLessThan: value)
                orderField = field
            case .lessThanOrEqualTo(let field, let value):
                queryTarget = queryTarget.whereField(field, isLessThanOrEqualTo: value)
                orderField = field
            case .greaterThan(let field, let value):
                queryTarget = queryTarget.whereField(field, isGreaterThan: value)
                orderField = field
            case .greaterThanOrEqualTo(let field, let value):
                queryTarget = queryTarget.whereField(field, isGreaterThanOrEqualTo: value)
                orderField = field
            }
            
            if let result = extract(field: orderField, from: orders) {
                orders.removeAll { $0 == result.order }
                queryTarget = queryTarget.order(by: result.field, descending: result.descending)
            }
            return queryTarget
            } ?? ref
        
        query = orders.reduce(query) { (result, order) -> Query in
            switch order {
            case .ascendingBy(let field):
                return query.order(by: field, descending: false)
            case .descendingBy(let field):
                return query.order(by: field, descending: true)
            }
        }
        
        return query
    }
    
    static func extract(field: String, from orders: [Order]) -> (order: Order, field: String, descending: Bool)? {
        for order in orders {
            switch order {
            case .ascendingBy(let orderField):
                if orderField == field {
                    return (order: order, field: field, descending: false)
                }
            case .descendingBy(let orderField):
                if orderField == field {
                    return (order: order, field: field, descending: true)
                }
            }
        }
        return nil
    }
}
