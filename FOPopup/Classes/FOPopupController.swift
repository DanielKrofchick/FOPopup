//
//  FOPopupController.swift
//  Pods
//
//  Created by Daniel Krofchick on 2016-07-18.
//
//

public class FOPopupController: UIViewController {
    
    var content: UIViewController!
    var snapThreshold = CGFloat(40)
    
    public convenience init(content: UIViewController) {
        self.init(nibName: nil, bundle: nil)
        
        content.transitioningDelegate = self
        content.modalPresentationStyle = .Custom
        self.content = content
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .Custom
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        presentViewController(content, animated: true, completion: nil)
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true) { 
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(recognizer.view)
        let velocity = recognizer.velocityInView(recognizer.view)
        let maxY = view.frame.height + content.view.frame.height / 2
        let minY = view.frame.height - content.view.frame.height / 2
        
        content.view.center = CGPoint(x: content.view.center.x, y: max(minY, min(content.view.center.y + translation.y, maxY)))
        
        switch recognizer.state {
        case .Possible, .Began, .Changed: break
        case .Ended, .Cancelled, .Failed:
            let anchors = closestAnchors()
            var upY: CGFloat? = nil
            var downY: CGFloat? = nil
            
            if let up = anchors.up {
                upY = view.frame.height - up.y
            }
            
            if let down = anchors.down {
                downY = view.frame.height - down.y
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
    }
    
    func snapToPoint(point: CGPoint) {
        if abs(view.frame.height - point.y) < snapThreshold {
            dismiss()
        } else {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                self.content.view.frame = CGRect(x: self.content.view.frame.origin.x, y: point.y, width: self.content.view.frame.width, height: self.content.view.frame.height)
            }, completion: nil)
        }
    }
    
    // Returns closes anchors up and down. nil if there is no anchor in a particular direction.
    func closestAnchors() -> (up: CGPoint?, down: CGPoint?) {
        let max = CGPoint(x: CGFloat.max, y: CGFloat.max)
        var up = max
        var down = max
        
        let currentY = view.frame.height - content.view.frame.origin.y
        
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
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FOPopupController: UIViewControllerTransitioningDelegate {

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FOPopoverAnimator(presenting: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FOPopoverAnimator(presenting: false)
    }

}
