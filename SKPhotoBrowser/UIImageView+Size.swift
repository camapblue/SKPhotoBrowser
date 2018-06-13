//
//  UIImageView+Size.swift
//  SKPhotoBrowser
//
//  Created by Toan Nguyen Cong on 6/13/18.
//  Copyright © 2018 suzuki_keishi. All rights reserved.
//

import Foundation

extension UIImageView {

    /// Find the size of the image, once the parent imageView has been given a contentMode of .scaleAspectFit
    /// Querying the image.size returns the non-scaled size. This helper property is needed for accurate results.
    func aspectFitSize(fromSize size: CGSize) -> CGSize {
        guard let image = image else { return CGSize.zero }
        
        var aspectFitSize = CGSize(width: size.width, height: size.height)
        let newWidth: CGFloat = size.width / image.size.width
        let newHeight: CGFloat = size.height / image.size.height
        
        if newHeight < newWidth {
            aspectFitSize.width = newHeight * image.size.width
        } else if newWidth < newHeight {
            aspectFitSize.height = newWidth * image.size.height
        }
        
        return aspectFitSize
    }
}
