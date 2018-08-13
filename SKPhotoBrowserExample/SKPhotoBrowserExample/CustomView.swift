//
//  CustomView.swift
//  SKPhotoBrowserExample
//
//  Created by Dao Le Quang on 4/10/18.
//  Copyright © 2018 suzuki_keishi. All rights reserved.
//

import Foundation
import SKPhotoBrowser

class CustomView: UIView, SKPhotoProtocol {
    open var index: Int = 0
    open var scrollEnable: Bool = false
    open var underlyingImage: UIImage?
    open var underlyingGifImage: FLAnimatedImage?
    open var customView: UIView?
    open var caption: String?
    open var shouldCachePhotoURLImage: Bool = false
    open var photoURL: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.customView = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(index: Int) {
        self.init()
        
        self.index = index
        self.customView = self
    }
    
    open func checkCache() { }
    
    open func loadUnderlyingImageAndNotify() {
        self.backgroundColor = UIColor.orange
        print("\nSET ORANGE NE")
    }
    
    open func loadUnderlyingImageComplete() {
    }
}
