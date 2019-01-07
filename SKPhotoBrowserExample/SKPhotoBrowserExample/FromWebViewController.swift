//
//  FromWebViewController.swift
//  SKPhotoBrowserExample
//
//  Created by suzuki_keishi on 2015/10/06.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import SDWebImage

class FromWebViewController: UIViewController, SKPhotoBrowserDelegate {
    @IBOutlet weak var imageView: SKAnimatedImageView!
    var images = [SKPhotoProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pushButton(_ sender: AnyObject) {
        SKCache.sharedCache.imageCache = FullScreenImageCache()
        let browser = SKPhotoBrowser(photos: [SKPhoto.photoWithImageURL("www.google.com")], initialPageIndex: 0)
        browser.photos = createWebPhotos()
        browser.initializePageIndex(0)
        browser.indicatorImages = loadingIndicator()
        browser.delegate = self
        
        present(browser, animated: true, completion: nil)
    }
    
    // Test loading custom indicator
    private func loadingIndicator() -> [UIImage] {
        return (1...30).compactMap { index -> UIImage? in return UIImage(named: "icon.fullscreenImage.progress\(index)")}
    }
}

// MARK: - SKPhotoBrowserDelegate

extension FromWebViewController {
    func didDismissAtPageIndex(_ index: Int) {
    }
    
    func didDismissActionSheetWithButtonIndex(_ buttonIndex: Int, photoIndex: Int) {
    }
    
    func removePhoto(index: Int, reload: (() -> Void)) {
        SKCache.sharedCache.removeImageForKey("somekey")
        reload()
    }
}

// MARK: - private

private extension FromWebViewController {
    func createWebPhotos() -> [SKPhotoProtocol] {
        return ["https://staticmbc-a.akamaihd.net/image/upload/v1541660634/2018/11/08/xumipum7bbcopeyt96ts.gif","https://staticmbc-a.akamaihd.net/image/upload/v1537844599/2018/09/25/fwjxz2sziojmebhlaams.gif","https://media0.giphy.com/media/13gvXfEVlxQjDO/giphy.gif", "https://images.pexels.com/photos/87840/daisy-pollen-flower-nature-87840.jpeg?cs=srgb&dl=plant-flower-macro-87840.jpg&fm=jpg",
         "https://thoughtcatalog.files.wordpress.com/2018/06/flower-puns.jpg?w=1140&resize=1140,761&quality=95&strip=all&crop=1",
         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_RUPdnqlOWJGrfNSgziTDNSTU0vSg62qkuKUa7FvNNzbR4B_AtA",
         "https://media.architecturaldigest.com/photos/57a263a6b6c434ab487bc2cb/master/pass/01.jpg",
         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXXy_4owokvieyYn5TrsR8zsrBdiIdW9MF7YY9_lKPkD5GLATI0w",
         "https://jooinn.com/images/fresh-roses-5.jpg", "https://www.flowerbowl.com.au/images/showcase/homepage/flowerbowl-26_preview.jpg"].map({ string -> SKPhotoProtocol in
            let photo = SKPhoto.photoWithImageURL(string)
            photo.shouldCachePhotoURLImage = true
            return photo
         })
    }
}

class FullScreenImageCache: SKImageCacheable {
    
    private let cache = SDImageCache.shared()
    
    func imageForKey(_ key: String) -> UIImage? {
        guard let image = cache.imageFromDiskCache(forKey: key) else { return nil }
        
        return image
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.store(image, forKey: key, toDisk: true)
    }
    
    func imageGifForKey(_ key: String) -> SKAnimatedImage? {
        guard let data = cache.diskImageData(forKey: key) else { return nil }
        
        return SKAnimatedImage(animatedGIFData: data)
    }
    
    func setGifImage(_ image: SKAnimatedImage, forKey key: String) {
        cache.storeImageData(toDisk: image.data, forKey: key)
    }
    
    func removeImageForKey(_ key: String) {}
    
    func removeAllImages() {}
    
}
