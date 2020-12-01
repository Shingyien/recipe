//
//  ImageStore.swift
//  Recipe
//
//  Created by Shing Yien on 01/12/2020.
//

import UIKit

struct ImageStore {
    static func retrieveImage(imageName: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            if let image = UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(imageName).path) {
                return image
            }
        }
        return nil
    }
    
    static func removeImage(imageName: String) -> Bool {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            do {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(imageName))
                return true
            } catch {
                return false
            }
        }
        return false
    }
}
