//
//  UIImageView.swift
//  SKPhotoBrowser
//
//  Created by Toan Nguyen Cong on 6/15/18.
//  Copyright © 2018 suzuki_keishi. All rights reserved.
//

import Foundation

extension UIImageView {
    
    func fadeImage(withAnimationDuration duration: TimeInterval = 1.0,
                   andImage image: UIImage,
                   completionHandler completion: ((Bool)-> Void)? = nil) {
        UIView.transition(with: self,
                          duration: 1.0, options: .transitionCrossDissolve, animations: {
                            self.image = image
        }, completion: completion)
    }
    
}
