//
//  RoundButton.swift
//  Listener
//
//  Created by Fei Liang on 9/30/17.
//  Copyright © 2017 Fei Liang. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }

    override func prepareForInterfaceBuilder() {
        setupView()
    }

    func setupView() {
        layer.cornerRadius = cornerRadius
    }

}
