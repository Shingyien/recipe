//
//  FirebaseStorageAdapter.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import Foundation
import Firebase

class FirebaseStorageAdapter: StorageAdapter {
    init() {
        self.storage = Storage.storage()
    }
    
    func getXMLFile(filename: String, callback: @escaping (Data) -> Void) {
        let fileRef = storage.reference(withPath: "xml/recipetype.xml")
        
        
        fileRef.getData(maxSize: 1024 * 1024 * 10) { (data, error) in
            if let error = error {
                print("Failed to fetch file \(filename) with error \(error)")
            } else {
                if let data = data {
                    callback(data)
                }
                
                print("Data \(String(decoding: data!, as: UTF8.self))")
            }
        }
    }
    
    let storage: Storage
}
