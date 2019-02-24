//
//  FireStorageRepository.swift
//  FireKit
//
//  Created by Takuya Yokoyama on 2019/02/24.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import FirebaseStorage

public class FireStorageRepository {
    private var uploadTask: StorageUploadTask?
    
    public init() {}
    
    deinit {
        uploadTask?.cancel()
    }
    
    public func put(_ imageData: Data, with name: String, completion: @escaping (URL?, Error?) -> Void) {
        uploadTask?.cancel()
        
        let ref = Storage.storage().reference().child("images/\(name).jpg")
        uploadTask = ref.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            ref.downloadURL { (url, error) in
                completion(url, error)
            }
        }
    }
}
