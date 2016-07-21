//
//  FOPopoverAnimator.swift
//  Pods
//
//  Created by Daniel Krofchick on 2016-07-19.
//
//

class FOPopoverAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting = false
    
    convenience init(presenting: Bool) {
        self.init()
        
        self.presenting = presenting
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            present(transitionContext)
        } else {
            dismiss(transitionContext)
        }
    }
    
    func present(transitionContext: UIViewControllerContextTransitioning) {
        if let
            from = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            to = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        {
            from.view.userInteractionEnabled = false
            transitionContext.containerView()?.addSubview(from.view)
            transitionContext.containerView()?.addSubview(to.view)
            transitionContext.containerView()?.addGestureRecognizer(dismisRecognizer(from))
            transitionContext.containerView()?.addGestureRecognizer(panRecognizer(from))
            
            let toS = to.preferredContentSize
            
            from.view.backgroundColor = UIColor(white: 0, alpha: 0)
            to.view.frame = CGRect(x: (from.view.frame.width - toS.width) / 2.0, y: from.view.frame.height, width: toS.width, height: toS.height)
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                from.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
                
                if let anchor = (to as? FOPopupProtocol)?.startAnchorPoint {
                    to.view.frame = CGRect(x: (from.view.frame.width - toS.width) / 2.0, y: from.view.frame.height - anchor.y, width: toS.width, height: toS.height)
                } else {
                    to.view.frame = CGRect(x: (from.view.frame.width - toS.width) / 2.0, y: from.view.frame.height - toS.height, width: toS.width, height: toS.height)
                }
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func dismiss(transitionContext: UIViewControllerContextTransitioning) {
        if let
            from = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            to = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        {
            to.view.userInteractionEnabled = true
            transitionContext.containerView()?.addSubview(from.view)
            transitionContext.containerView()?.addSubview(to.view)
            
            let fromS = from.preferredContentSize
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                to.view.backgroundColor = UIColor(white: 0, alpha: 0)
                from.view.frame = CGRect(x: (to.view.frame.width - fromS.width) / 2.0, y: to.view.frame.height, width: fromS.width, height: fromS.height)
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
                UIApplication.sharedApplication().keyWindow?.addSubview(to.view)
            })
        }
    }
    
    func dismisRecognizer(target: AnyObject?) -> UIGestureRecognizer {
        let recognizer = UITapGestureRecognizer(target: target, action: #selector(FOPopupController.dismiss))
        
        if let target = target as? UIGestureRecognizerDelegate {
            recognizer.delegate = target
        }
        
        return recognizer
    }
    
    func panRecognizer(target: AnyObject?) -> UIGestureRecognizer {
        let recognizer = UIPanGestureRecognizer(target: target, action: #selector(FOPopupController.pan))
        
        if let target = target as? UIGestureRecognizerDelegate {
            recognizer.delegate = target
        }
        
        return recognizer
    }
    
}
