//
//  FOPopup.swift
//  Pods
//
//  Created by Daniel Krofchick on 2016-07-18.
//
//

public protocol FOPopupProtocol: class {
    // snap points
    var anchorPoints: [CGPoint]? {get set}
    // snap point when controller is first revealed
    var startAnchorPoint: CGPoint? {get set}
    
    // the controller will animate to the snap point
    // return it or change the destination
    func willSnapToPoint(_ point: CGPoint) -> CGPoint?
    
    // pan recognizer forwarding
    func didPan(_ recognizer: UIPanGestureRecognizer)
}

extension FOPopupProtocol {
    
    func willSnapToPoint(_ point: CGPoint) -> CGPoint? {
        return point
    }
    
    func didPan(_ recognizer: UIPanGestureRecognizer) {
    }

}

open class FOPopup: NSObject {
    
    open var content: UIViewController!
    var delegate: FOPopupProtocol? {
        return content as? FOPopupProtocol
    }
    var snapThreshold: CGFloat = 40
    let background = UIView()

    // retains itself until the content is dismissed
    var selfRef: AnyObject?
    
    public required init(content: UIViewController) {
        super.init()

        selfRef = self

        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        background.backgroundColor = .black
        
        content.transitioningDelegate = self
        content.modalPresentationStyle = .custom
        self.content = content

        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) {
            [weak self] _ in
            if let this = self {
                let contentS = content.preferredContentSize
                let viewS = this.presenting().view.frame.size
                
                UIView.animate(withDuration: 0.3, animations: {
                    this.content.view.frame = CGRect(x: (viewS.width - contentS.width) / 2, y: this.content.view.frame.origin.y, width: contentS.width, height: contentS.height)
                }) 
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func dismiss() {
        content.dismiss(animated: true, completion: nil)
    }
    
    func presenting() -> UIViewController {
        return content.presentingViewController!
    }
    
}

// Gesture
extension FOPopup {
    
    @objc func pan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view)
        let velocity = recognizer.velocity(in: recognizer.view)
        let maxY = presenting().view.frame.height + content.view.frame.height / 2
        let minY = presenting().view.frame.height - content.view.frame.height / 2
        
        content.view.center = CGPoint(x: content.view.center.x, y: max(minY, min(content.view.center.y + translation.y, maxY)))
        
        switch recognizer.state {
        case .possible, .began, .changed: break
        case .ended, .cancelled, .failed:
            let anchors = closestAnchors()
            var upY: CGFloat? = nil
            var downY: CGFloat? = nil
            
            if let up = anchors.up {
                upY = presenting().view.frame.height - up.y
            }
            
            if let down = anchors.down {
                downY = presenting().view.frame.height - down.y
            }
            
            if let upY = upY, abs(upY - content.view.frame.origin.y) <= snapThreshold {
                snapToPoint(CGPoint(x: 0, y: upY))
            } else if let downY = downY, abs(downY - content.view.frame.origin.y) <= snapThreshold {
                snapToPoint(CGPoint(x: 0, y: downY))
            } else if let upY = upY, velocity.y > 0 {
                snapToPoint(CGPoint(x: 0, y: upY))
            } else if let downY = downY, velocity.y < 0 {
                snapToPoint(CGPoint(x: 0, y: downY))
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        
        delegate?.didPan(recognizer)
    }
    
    func snapToPoint(_ point: CGPoint) {
        let p = delegate?.willSnapToPoint(point) ?? point
        
        if abs(presenting().view.frame.height - p.y) < snapThreshold {
            dismiss()
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.content.view.frame = CGRect(x: self.content.view.frame.origin.x, y: p.y, width: self.content.view.frame.width, height: self.content.view.frame.height)
            }, completion: nil)
        }
    }
    
    // Returns closes anchors up and down. nil if there is no anchor in a particular direction.
    public func closestAnchors() -> (up: CGPoint?, down: CGPoint?) {
        let max = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
        var up = max
        var down = max
        
        let currentY = presenting().view.frame.height - content.view.frame.origin.y
        
        delegate?.anchorPoints?.forEach { anchor in
            if currentY - anchor.y >= 0 && currentY - anchor.y < abs(currentY - up.y) {
                up = anchor
            }
            
            if currentY - anchor.y <= 0 && currentY - anchor.y > currentY - down.y {
                down = anchor
            }
        }
        
        return (up == max ? nil : up, down == max ? nil : down)
    }

}

extension FOPopup: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var should = true
        
        if let gestureRecognizer = gestureRecognizer as? UITapGestureRecognizer {
            if content.view.frame.contains(gestureRecognizer.location(in: presenting().view)) {
                should = false
            }
        }
        
        return should
    }
    
}

extension FOPopup: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FOPopupAnimator(presenting: true, popup: self)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FOPopupAnimator(presenting: false, popup: self)
    }

}
