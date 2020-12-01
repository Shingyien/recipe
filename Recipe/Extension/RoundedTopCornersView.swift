//
//  RoundedTopCornersView.swift
//  Recipe
//
//  Created by Shing Yien on 28/11/2020.
//

import UIKit

class RoundedTopCornersView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var enableGradient: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        clipsToBounds = true
        
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
