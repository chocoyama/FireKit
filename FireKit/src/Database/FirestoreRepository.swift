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
}

extension FirestoreRepository {
    public func create(_ entity: T, completion: @escaping (Result<T, FirestoreRepositoryError>) -> Void) {
        var ref: DocumentReference?
        ref = collectionRef.addDocument(data: entity.toFirestoreData()) { (error) in
            if let error = error {
                completion(.failure(.unknown(error)))
            } else {
                if let documentId = ref?.documentID {
                    var updatedEntity = entity
                    updatedEntity.firestoreId = documentId
                    completion(.success(updatedEntity))
                } else {
                    completion(.failure(.notFoundDocumentId))
                }
            }
        }
    }
}

extension FirestoreRepository {
    public func get(id: String, completion: @escaping (Result<T?, FirestoreRepositoryError>) -> Void) {
        collectionRef.document(id).getDocument { (docSnapshot, error) in
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }
            
            guard let id = docSnapshot?.documentID, let data = docSnapshot?.data() else {
                completion(.success(nil))
                return
            }
            
            completion(.success(T(firestoreId: id, firestoreData: data)))
        }
    }
    
    public func get(searchQuery: [SearchQuery]? = nil, completion: @escaping (Result<[T], FirestoreRepositoryError>) -> Void) {
        let query = FirestoreQueryBuilder.build(for: collectionRef, by: searchQuery)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }
            
            let entities = querySnapshot?.documents.compactMap { docSnapShot -> T? in
                T(firestoreId: docSnapShot.documentID,
                  firestoreData: docSnapShot.data())
            }
            completion(.success(entities ?? []))
        }
    }
}

extension FirestoreRepository {
    public func listen(id: String, listener: @escaping (Result<T?, FirestoreRepositoryError>) -> Void) {
        registration?.remove()
        
        registration = collectionRef.document(id).addSnapshotListener { (docSnapshot, error) in
            if let error = error {
                listener(.failure(.unknown(error)))
                return
            }
            
            guard let id = docSnapshot?.documentID, let data = docSnapshot?.data() else {
                listener(.success(nil))
                return
            }
            listener(.success(T(firestoreId: id, firestoreData: data)))
        }
    }
    
    public func listen(searchQuery: [SearchQuery]? = nil, listener: @escaping ((Result<[T], FirestoreRepositoryError>) -> Void)) {
        registration?.remove()
        
        let query = FirestoreQueryBuilder.build(for: collectionRef, by: searchQuery)
        registration = query.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                listener(.failure(.unknown(error)))
                return
            }
            
            let entities = querySnapshot?.documents.compactMap {
                T(firestoreId: $0.documentID,
                  firestoreData: $0.data())
            }
            
            listener(.success(entities ?? []))
        }
    }
}

extension FirestoreRepository {
    public func update(_ fields: [AnyHashable: Any], id: String, completion: @escaping (Result<Void, FirestoreRepositoryError>) -> Void) {
        collectionRef.document(id).updateData(fields) { (error) in
            if let error = error {
                completion(.failure(.unknown(error)))
            } else {
                completion(.success(()))
            }
        }
    }
}

extension FirestoreRepository {
    public func delete(id: String, completion: @escaping (Result<Void, FirestoreRepositoryError>) -> Void) {
        collectionRef.document(id).delete { (error) in
            if let error = error {
                completion(.failure(.unknown(error)))
            } else {
                completion(.success(()))
            }
        }
    }
}
