//
//  AnimatedButton.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 04/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import UIKit

class AnimatedButton: UIButton {
    @IBInspectable var color:   UIColor = .black {didSet { updateColor() }}
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupAnimation()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupAnimation()
    }
    
    private func setup() {
        layer.cornerRadius = frame.height/2
    }
    
    private func updateColor() {
        layer.backgroundColor = color.cgColor
    }
    
    private func setupAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        layer.add(pulseAnimation, forKey: "animateOpacity")
    }
}
