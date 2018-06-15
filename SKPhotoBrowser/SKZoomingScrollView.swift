//
//  SKZoomingScrollView.swift
//  SKViewExample
//
//  Created by suzuki_keihsi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

open class SKZoomingScrollView: UIScrollView {
    var captionView: SKCaptionView!
    var isRightToLeft = false
    var photo: SKPhotoProtocol! {
        didSet {
            imageView.image = nil
            if photo != nil {
                if photo.customView != nil {
                    displayCustomView(complete: false)
                } else if photo.underlyingImage != nil {
                    displayImage(complete: true)
                }
            }
            if photo != nil {
                displayImage(complete: false)
            }
            
            if isRightToLeft {
                self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }
        }
    }
    
    public var indicatorImages: [UIImage]?
    
    fileprivate weak var browser: SKPhotoBrowser?
    
    fileprivate(set) var imageView: SKDetectingImageView!
    fileprivate var tapView: SKDetectingView!
    fileprivate var indicatorView: SKIndicatorView!
    fileprivate var indicatorImageView: UIImageView?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser, indicatorImages: [UIImage]?) {
        self.init(frame: frame)
        self.browser = browser
        self.indicatorImages = indicatorImages
        setup()
    }
    
    deinit {
        browser = nil
    }
    
    func setup() {
        // tap
        tapView = SKDetectingView(frame: bounds)
        tapView.delegate = self
        tapView.backgroundColor = .clear
        tapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(tapView)
        
        // image
        imageView = SKDetectingImageView(frame: frame)
        imageView.delegate = self
        imageView.contentMode = .center
        imageView.backgroundColor = .clear
        addSubview(imageView)
        
        // indicator || customer indicator image view
        if let indicatorImages = indicatorImages {
            indicatorImageView = UIImageView()
            indicatorImageView?.frame = frame
            indicatorImageView?.frame.size = SKPhotoBrowserOptions.indicatorCustomSize
            indicatorImageView?.contentMode = .scaleAspectFit
            indicatorImageView?.animationImages = indicatorImages
            addSubview(indicatorImageView!)
        } else {
            indicatorView = SKIndicatorView(frame: frame)
            addSubview(indicatorView)
        }
        
        // self
        backgroundColor = .clear
        delegate = self
        showsHorizontalScrollIndicator = SKPhotoBrowserOptions.displayHorizontalScrollIndicator
        showsVerticalScrollIndicator = SKPhotoBrowserOptions.displayVerticalScrollIndicator
        decelerationRate = UIScrollViewDecelerationRateFast
        autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin]
    }
    
    // MARK: - override
    
    open override func layoutSubviews() {
        tapView.frame = bounds
        // check custom indicator
        if let indicatorImageView = indicatorImageView {
            indicatorImageView.frame = bounds
            indicatorImageView.frame.size = SKPhotoBrowserOptions.indicatorCustomSize
            indicatorImageView.center = browser?.view.center ?? center
        } else {
            indicatorView.frame = bounds
        }

        super.layoutSubviews()

        let boundsSize = bounds.size
        var frameToCenter = imageView.frame

        // horizon
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2)
        } else {
            frameToCenter.origin.x = 0
        }
        // vertical
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2)
        } else {
            frameToCenter.origin.y = 0
        }

        // Center
        if !imageView.frame.equalTo(frameToCenter) {
            imageView.frame = frameToCenter
        }
    }

    open func setMaxMinZoomScalesForCurrentBounds() {
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1

        guard let imageView = imageView else {
            return
        }

        let boundsSize = bounds.size
        let imageSize = imageView.frame.size

        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        var minScale: CGFloat = min(xScale, yScale)
        var maxScale: CGFloat = 1.0

        let scale = max(SKMesurement.screenScale, 2.0)
        let deviceScreenWidth = UIScreen.main.bounds.width * scale // width in pixels. scale needs to remove if to use the old algorithm
        let deviceScreenHeight = UIScreen.main.bounds.height * scale // height in pixels. scale needs to remove if to use the old algorithm

        if SKPhotoBrowserOptions.longPhotoWidthMatchScreen && imageView.frame.height >= imageView.frame.width {
            minScale = 1.0
            maxScale = 2.5
        } else if imageView.frame.width < deviceScreenWidth {
            // I think that we should to get coefficient between device screen width and image width and assign it to maxScale. I made two mode that we will get the same result for different device orientations.
            if UIApplication.shared.statusBarOrientation.isPortrait {
                maxScale = deviceScreenHeight / imageView.frame.width
            } else {
                maxScale = deviceScreenWidth / imageView.frame.width
            }
        } else if imageView.frame.width > deviceScreenWidth {
            maxScale = 1.0
        } else {
            // here if imageView.frame.width == deviceScreenWidth
            maxScale = 2.5
        }

        maximumZoomScale = maxScale
        // minimumZoomScale is not correct when the image's size smaller than device screen
        minimumZoomScale = minScale > 1.0 ? 1.0 : minScale
        zoomScale = minimumZoomScale

        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5
        // After changing this value, we still never use more
        /*
        maxScale = maxScale / scale
        if maxScale < minScale {
            maxScale = minScale * 2
        }
        */

        // reset position
        imageView.frame.origin = CGPoint.zero
        setNeedsLayout()
    }
    
    open func prepareForReuse() {
        photo = nil
        if captionView != nil {
            captionView.removeFromSuperview()
            captionView = nil 
        }
    }
    
    // MARK: - image
    open func displayImage(complete flag: Bool) {
        // reset scale
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        if !flag {
            if photo.underlyingImage == nil {
                animationIndicator()
            }
            photo.loadUnderlyingImageAndNotify()
        } else {
            animationIndicator(isAnimating: false)
        }
        
        if let image = photo.underlyingImage, photo != nil {
            // image
            imageView.fadeImage(withAnimationDuration: SKPhotoBrowserOptions.fadeAnimationDuration,
                                andImage: image)
            imageView.clipsToBounds = true
            
            var imageViewFrame: CGRect = .zero
            imageViewFrame.origin = .zero
            
            // check photo size
            let photoWidth = image.size.width
            let photoHeight = image.size.height
        
            // image smaller than the device screen
            if photoWidth < SKMesurement.screenWidth && photoHeight < SKMesurement.screenHeight {
                imageViewFrame.size = image.size
            } else if photoWidth > SKMesurement.screenWidth && photoHeight < SKMesurement.screenHeight {
                let screenSize = CGSize(width: SKMesurement.screenWidth, height: photoHeight)
                imageViewFrame.size = CGSize(width: imageView.aspectFitSize(fromSize: screenSize).width,
                                             height: imageView.aspectFitSize(fromSize: screenSize).height)
            } else if photoHeight > SKMesurement.screenHeight && photoWidth < SKMesurement.screenWidth {
                let screenSize = CGSize(width: photoWidth, height: SKMesurement.screenHeight)
                imageViewFrame.size = CGSize(width: imageView.aspectFitSize(fromSize: screenSize).width,
                                             height: imageView.aspectFitSize(fromSize: screenSize).height)
            } else if photoWidth > SKMesurement.screenWidth && photoHeight > SKMesurement.screenHeight {
                let screenSize = CGSize(width: SKMesurement.screenWidth, height: SKMesurement.screenHeight)
                imageViewFrame.size = CGSize(width: imageView.aspectFitSize(fromSize: screenSize).width,
                                             height: imageView.aspectFitSize(fromSize: screenSize).height)
            }
            
            imageView.contentMode = .scaleAspectFit
            imageView.frame = imageViewFrame

            contentSize = imageViewFrame.size
            setMaxMinZoomScalesForCurrentBounds()
		} else {
			// change contentSize will reset contentOffset, so only set the contentsize zero when the image is nil
			contentSize = CGSize.zero
		}
        setNeedsLayout()
    }
    
    open func displayCustomView(complete flag: Bool) {
        // reset scale
        maximumZoomScale = 1
        minimumZoomScale = 1
        zoomScale = 1
        
        if !flag {
            if photo.customView == nil {
                animationIndicator()
            }
            photo.loadUnderlyingImageAndNotify()
        } else {
            animationIndicator(isAnimating: false)
        }
        if let view = photo.customView, let parent = imageView.superview {
            // image
            parent.addSubview(view)
            
            view.frame = parent.bounds
        } else {
            // change contentSize will reset contentOffset, so only set the contentsize zero when the image is nil
            contentSize = CGSize.zero
        }
        setNeedsLayout()
    }
    
    open func displayImageFailure() {
        animationIndicator(isAnimating: false)
    }
    
    // MARK: - handle tap
    open func handleDoubleTap(_ touchPoint: CGPoint) {
        if let browser = browser {
            NSObject.cancelPreviousPerformRequests(withTarget: browser)
        }
        
        if zoomScale > minimumZoomScale {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            // zoom in
            // I think that the result should be the same after double touch or pinch
           /* var newZoom: CGFloat = zoomScale * 3.13
            if newZoom >= maximumZoomScale {
                newZoom = maximumZoomScale
            }
            */
            let zoomRect = zoomRectForScrollViewWith(maximumZoomScale, touchPoint: touchPoint)
            zoom(to: zoomRect, animated: true)
        }
        
        // delay control
        browser?.hideControlsAfterDelay()
    }
    
    // MARK: - private func
    private func animationIndicator(isAnimating animating: Bool = true) {
        if let indicatorImageView = indicatorImageView {
            animating ? indicatorImageView.startAnimating() : indicatorImageView.stopAnimating()
        } else {
            animating ? indicatorView.startAnimating() : indicatorView.stopAnimating()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SKZoomingScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        browser?.cancelControlHiding()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - SKDetectingImageViewDelegate

extension SKZoomingScrollView: SKDetectingViewDelegate {
    func handleSingleTap(_ view: UIView, touch: UITouch) {
        guard let browser = browser else {
            return
        }
        guard SKPhotoBrowserOptions.enableZoomBlackArea == true else {
            return
        }
        
        if browser.areControlsHidden() == false && SKPhotoBrowserOptions.enableSingleTapDismiss == true {
            browser.determineAndClose()
        } else {
            browser.toggleControls()
        }
    }
    
    func handleDoubleTap(_ view: UIView, touch: UITouch) {
        if SKPhotoBrowserOptions.enableZoomBlackArea == true {
            let needPoint = getViewFramePercent(view, touch: touch)
            handleDoubleTap(needPoint)
        }
    }
}

// MARK: - SKDetectingImageViewDelegate

extension SKZoomingScrollView: SKDetectingImageViewDelegate {
    func handleImageViewSingleTap(_ touchPoint: CGPoint) {
        guard let browser = browser else {
            return
        }
        if SKPhotoBrowserOptions.enableSingleTapDismiss {
            browser.determineAndClose()
        } else {
            browser.toggleControls()
        }
    }
    
    func handleImageViewDoubleTap(_ touchPoint: CGPoint) {
        handleDoubleTap(touchPoint)
    }
}

private extension SKZoomingScrollView {
    func getViewFramePercent(_ view: UIView, touch: UITouch) -> CGPoint {
        let oneWidthViewPercent = view.bounds.width / 100
        let viewTouchPoint = touch.location(in: view)
        let viewWidthTouch = viewTouchPoint.x
        let viewPercentTouch = viewWidthTouch / oneWidthViewPercent
        let photoWidth = imageView.bounds.width
        let onePhotoPercent = photoWidth / 100
        let needPoint = viewPercentTouch * onePhotoPercent
        
        var Y: CGFloat!
        
        if viewTouchPoint.y < view.bounds.height / 2 {
            Y = 0
        } else {
            Y = imageView.bounds.height
        }
        let allPoint = CGPoint(x: needPoint, y: Y)
        return allPoint
    }
    
    func zoomRectForScrollViewWith(_ scale: CGFloat, touchPoint: CGPoint) -> CGRect {
        let w = frame.size.width / scale
        let h = frame.size.height / scale
        let x = touchPoint.x - (h / max(UIScreen.main.scale, 2.0))
        let y = touchPoint.y - (w / max(UIScreen.main.scale, 2.0))
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
