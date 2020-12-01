//
//  StorageAdapter.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import Foundation

protocol StorageAdapter {
    func getXMLFile(filename: String, callback: @escaping (Data) -> Void);
}
