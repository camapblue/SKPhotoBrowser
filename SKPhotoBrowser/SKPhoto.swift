//
//  SKPhoto.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

@objc public protocol SKPhotoProtocol: NSObjectProtocol {
    var index: Int { get set }
    var scrollEnable: Bool { get set }
    var underlyingImage: UIImage? { get }
    var underlyingGifImage: SKAnimatedImage? { get }
    var customView: UIView? { get }
    var caption: String? { get }
    var contentMode: UIView.ContentMode { get set }
    func loadUnderlyingImageAndNotify()
    func checkCache() -> Bool
}

// MARK: - SKPhoto
open class SKPhoto: NSObject, SKPhotoProtocol {
    open var index: Int = 0
    open var scrollEnable: Bool = true
    open var underlyingImage: UIImage?
    open var underlyingGifImage: SKAnimatedImage?
    open var customView: UIView?
    open var caption: String?
    open var contentMode: UIView.ContentMode = .scaleAspectFill
    open var shouldCachePhotoURLImage: Bool = false
    open var photoURL: String!

    override init() {
        super.init()
    }
    
    convenience init(image: UIImage) {
        self.init()
        underlyingImage = image
    }
    
    convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    convenience init(url: String, holder: UIImage?) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    open func checkCache() -> Bool {
        guard let photoURL = photoURL else {
            return false
        }
        guard shouldCachePhotoURLImage else {
            return false
        }
        
        let isGif = photoURL.contains("gif") == true
        
        if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
            let request = URLRequest(url: URL(string: photoURL)!)
            if isGif {
                underlyingGifImage = SKCache.sharedCache.imageGifForRequest(request)
            } else {
                underlyingImage = SKCache.sharedCache.imageForRequest(request)
            }
        } else {
            if isGif {
                underlyingGifImage = SKCache.sharedCache.imageGifForKey(photoURL)
            } else {
                underlyingImage = SKCache.sharedCache.imageForKey(photoURL)
            }
        }
        
        if isGif, underlyingGifImage != nil {
            self.loadUnderlyingImageComplete()
            return true
        }
        
        if !isGif, underlyingImage != nil {
            self.loadUnderlyingImageComplete()
            return true
        }
        
        return false
    }
    
    open func loadUnderlyingImageAndNotify() {
        guard photoURL != nil, let URL = URL(string: photoURL) else { return }
        var isGif = photoURL.contains("gif") ==  true
        
        // Get image from cache before load
        if checkCache() { return }
        
        // Fetch Image
        let session = URLSession(configuration: SKPhotoBrowserOptions.sessionConfiguration)
            var task: URLSessionTask?
            task = session.dataTask(with: URL, completionHandler: { [weak self] (data, response, error) in
                guard let `self` = self else { return }
                defer { session.finishTasksAndInvalidate() }

                guard error == nil else {
                    DispatchQueue.main.async {
                        self.loadUnderlyingImageComplete()
                    }
                    return
                }

                if let data = data, let response = response, let image = UIImage(data: data) {
                    if self.shouldCachePhotoURLImage {
                        if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
                            SKCache.sharedCache.setImageData(data, response: response, request: task?.originalRequest)
                        } else {
                            if isGif {
                                SKCache.sharedCache.setGifImage(SKAnimatedImage(animatedGIFData: data),
                                                                forKey: self.photoURL)
                            } else {
                                SKCache.sharedCache.setImage(image, forKey: self.photoURL)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        if isGif {
                            self.underlyingGifImage = SKAnimatedImage(animatedGIFData: data)
                        } else {
                            self.underlyingImage = image
                        }
                        self.loadUnderlyingImageComplete()
                    }
                }
                
            })
            task?.resume()
    }

    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
}

// MARK: - Static Function

extension SKPhoto {
    public static func photoWithImage(_ image: UIImage) -> SKPhoto {
        return SKPhoto(image: image)
    }
    
    public static func photoWithImageURL(_ url: String) -> SKPhoto {
        return SKPhoto(url: url)
    }
    
    public static func photoWithImageURL(_ url: String, holder: UIImage?) -> SKPhoto {
        return SKPhoto(url: url, holder: holder)
    }
}
