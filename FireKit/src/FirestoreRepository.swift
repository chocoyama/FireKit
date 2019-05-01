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
    
    public func create(_ entity: T, completion: ((Result<Void, Error>) -> Void)?) {
        collectionRef.addDocument(data: entity.toFirestoreData()) { (error) in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    public func get(equalQuery: [String: Any]? = nil, completion: ((Result<[T], Error>) -> Void)?) {
        let ref = collectionRef
        
        let query = equalQuery?.enumerated().reduce(ref) { (query: Query, value: (offset: Int, element: (key: String, value: Any))) -> Query in
            if value.offset == 0 {
                return ref.whereField(value.element.key, isEqualTo: value.element.value)
            } else {
                return query.whereField(value.element.key, isEqualTo: value.element.value)
            }
        }
        
        (query ?? ref).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            let entities = querySnapshot?.documents.compactMap { docSnapShot -> T? in
                T(firestoreId: docSnapShot.documentID,
                  firestoreData: docSnapShot.data())
            }
            completion?(.success(entities ?? []))
        }
    }
    
    public func listenAll(listener: @escaping (Result<[T], Error>) -> Void) {
        registration?.remove()
        
        registration = collectionRef.addSnapshotListener({ (querySnapshot, error) in
            if let error = error {
                listener(.failure(error))
                return
            }
            
            let entities = querySnapshot?.documents.compactMap {
                T(firestoreId: $0.documentID,
                  firestoreData: $0.data())
            }
            listener(.success(entities ?? []))
        })
    }
    
    public func listen(id: String, listener: @escaping (Result<T?, Error>) -> Void) {
        registration?.remove()
        
        registration = collectionRef.document(id).addSnapshotListener { (docSnapshot, error) in
            if let error = error {
                listener(.failure(error))
                return
            }
            
            guard let id = docSnapshot?.documentID, let data = docSnapshot?.data() else {
                listener(.success(nil))
                return
            }
            listener(.success(T(firestoreId: id, firestoreData: data)))
        }
    }
    
    public func update(_ fields: [String: [String]], in id: String, completion: ((Result<Void, Error>) -> Void)?) {
        collectionRef.document(id).updateData(fields) { (error) in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }
}
