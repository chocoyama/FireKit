//
//  FirestoreRepository.swift
//  FireKit
//
//  Created by Takuya Yokoyama on 2019/02/24.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import FirebaseFirestore

public class FirestoreRepository<T: FirestoreCompatible> {
    private var registration: ListenerRegistration?
    
    public init() {}
    
    deinit {
        registration?.remove()
    }
    
    private var collectionRef: CollectionReference {
        return Firestore.firestore().collection(T.collectionName)
    }
    
    public func create(_ entity: T, completion: ((Error?) -> Void)?) {
        collectionRef.addDocument(data: entity.toFirestoreData(), completion: completion)
    }
    
    public func get(equalQuery: [String: Any], completion: ((T?, Error?) -> Void)?) {
        let ref = collectionRef
        
        let query = equalQuery.enumerated().reduce(ref) { (query: Query, value: (offset: Int, element: (key: String, value: Any))) -> Query in
            if value.offset == 0 {
                return ref.whereField(value.element.key, isEqualTo: value.element.value)
            } else {
                return query.whereField(value.element.key, isEqualTo: value.element.value)
            }
        }
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion?(nil, error)
                return
            }
            
            let entity = querySnapshot?.documents.compactMap { docSnapShot -> T? in
                T(firestoreId: docSnapShot.documentID,
                  firestoreData: docSnapShot.data())
            }.first
            
            completion?(entity, nil)
        }
    }
    
    public func listenAll(listener: @escaping ([T]) -> Void) {
        registration?.remove()
        
        registration = collectionRef.addSnapshotListener({ (querySnapshot, error) in
            let entities = querySnapshot?.documents.compactMap {
                T(firestoreId: $0.documentID,
                  firestoreData: $0.data())
            }
            listener(entities ?? [])
        })
    }
    
    public func listen(id: String, listener: @escaping (T?) -> Void) {
        registration?.remove()
        
        registration = collectionRef.document(id).addSnapshotListener { (docSnapshot, error) in
            guard let id = docSnapshot?.documentID, let data = docSnapshot?.data() else {
                listener(nil)
                return
            }
            listener(T(firestoreId: id, firestoreData: data))
        }
    }
    
    public func update(_ fields: [String: [String]], in id: String, completion: ((Error?) -> Void)?) {
        collectionRef.document(id).updateData(fields, completion: completion)
    }
}
