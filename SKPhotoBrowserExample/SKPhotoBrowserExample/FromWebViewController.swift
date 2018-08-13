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
    @IBOutlet weak var imageView: FLAnimatedImageView!
    var images = [SKPhotoProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pushButton(_ sender: AnyObject) {
        let browser = SKPhotoBrowser(photos: createWebPhotos(), initialPageIndex: 0)
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
        return (0..<10).map { (i: Int) -> SKPhotoProtocol in
//            let photo = SKPhoto.photoWithImageURL("https://placehold.jp/150\(i)x150\(i).png", holder: UIImage(named: "image0.jpg")!)
            let photo = SKPhoto.photoWithImageURL("https://media0.giphy.com/media/13gvXfEVlxQjDO/giphy.gif")
            photo.caption = caption[i%10]
            photo.shouldCachePhotoURLImage = true
            return photo
        }
    }
}

