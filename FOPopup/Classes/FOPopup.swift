//
//  FOPopup.swift
//  Pods
//
//  Created by Daniel Krofchick on 2016-07-18.
//
//

public protocol FOPopupProtocol {
    
    var anchorPoints: [CGPoint]? {get set}
    var startAnchorPoint: CGPoint? {get set}
    weak var popup: FOPopup? {get set}
    func willSnapToPoint(point: CGPoint) -> CGPoint?
    func didPan(recognizer: UIPanGestureRecognizer)
    
}

extension FOPopupProtocol {
    
    func willSnapToPoint(point: CGPoint) -> CGPoint? {
        return point
    }
    
    func didPan(recognizer: UIPanGestureRecognizer) {
    }

}

public class FOPopup: NSObject {
    
    public var content: UIViewController!
    var snapThreshold = CGFloat(40)
    let background = UIView()
    var retainer: AnyObject? = nil // Retians this object until the content is dismissed.
    
    public required init(content: UIViewController) {
        super.init()

        retainer = self

        background.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        background.backgroundColor = UIColor.blackColor()
        
        if var content = content as? FOPopupProtocol {
            content.popup = self
            
            if var content = content as? UIViewController {
                content.transitioningDelegate = self
                content.modalPresentationStyle = .Custom
                self.content = content
            }
        }

        NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: .mainQueue()) {
            [weak self] _ in
            if let this = self {
                let contentS = content.preferredContentSize
                let viewS = this.presenting().view.frame.size
                let y = viewS.height - (viewS.width - content.view.frame.origin.y)
                
                UIView.animateWithDuration(0.3) {
                    this.content.view.frame = CGRect(x: (viewS.width - contentS.width) / 2, y: y, width: contentS.width, height: contentS.height)
                }
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func dismiss() {
        content.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presenting() -> UIViewController {
        return content.presentingViewController!
    }
    
}

// Gesture
extension FOPopup {
    
    func pan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(recognizer.view)
        let velocity = recognizer.velocityInView(recognizer.view)
        let maxY = presenting().view.frame.height + content.view.frame.height / 2
        let minY = presenting().view.frame.height - content.view.frame.height / 2
        
        content.view.center = CGPoint(x: content.view.center.x, y: max(minY, min(content.view.center.y + translation.y, maxY)))
        
        switch recognizer.state {
        case .Possible, .Began, .Changed: break
        case .Ended, .Cancelled, .Failed:
            let anchors = closestAnchors()
            var upY: CGFloat? = nil
            var downY: CGFloat? = nil
            
            if let up = anchors.up {
                upY = presenting().view.frame.height - up.y
            }
            
            if let down = anchors.down {
                downY = presenting().view.frame.height - down.y
            }
            
            if let upY = upY where abs(upY - content.view.frame.origin.y) <= snapThreshold {
                snapToPoint(CGPoint(x: 0, y: upY))
            } else if let downY = downY where abs(downY - content.view.frame.origin.y) <= snapThreshold {
                snapToPoint(CGPoint(x: 0, y: downY))
            } else if let upY = upY where velocity.y > 0 {
                snapToPoint(CGPoint(x: 0, y: upY))
            } else if let downY = downY where velocity.y < 0 {
                snapToPoint(CGPoint(x: 0, y: downY))
            }
        }
        
        recognizer.setTranslation(CGPointZero, inView: recognizer.view)
        
        if let content = content as? FOPopupProtocol {
            content.didPan(recognizer)
        }
    }
    
    func snapToPoint(point: CGPoint) {
        if let
            content = content as? FOPopupProtocol,
            p = content.willSnapToPoint(point)
        {
            if abs(presenting().view.frame.height - p.y) < snapThreshold {
                dismiss()
            } else {
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                    self.content.view.frame = CGRect(x: self.content.view.frame.origin.x, y: p.y, width: self.content.view.frame.width, height: self.content.view.frame.height)
                    }, completion: nil)
            }
        }
    }
    
    // Returns closes anchors up and down. nil if there is no anchor in a particular direction.
    func closestAnchors() -> (up: CGPoint?, down: CGPoint?) {
        let max = CGPoint(x: CGFloat.max, y: CGFloat.max)
        var up = max
        var down = max
        
        let currentY = presenting().view.frame.height - content.view.frame.origin.y
        
        if let anchors = (content as? FOPopupProtocol)?.anchorPoints {
            anchors.forEach { anchor in
                if currentY - anchor.y >= 0 && currentY - anchor.y < abs(currentY - up.y) {
                    up = anchor
                }
                
                if currentY - anchor.y <= 0 && currentY - anchor.y > currentY - down.y {
                    down = anchor
                }
            }
        }
        
        return (up == max ? nil : up, down == max ? nil : down)
    }

}

extension FOPopup: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        var should = true
        
        if let gestureRecognizer = gestureRecognizer as? UITapGestureRecognizer {
            if content.view.frame.contains(gestureRecognizer.locationInView(presenting().view)) {
                should = false
            }
        }
        
        return should
    }
    
}

extension FOPopup: UIViewControllerTransitioningDelegate {

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FOPopupAnimator(presenting: true, popup: self)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FOPopupAnimator(presenting: false, popup: self)
    }

}
