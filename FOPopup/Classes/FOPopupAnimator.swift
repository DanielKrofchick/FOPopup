//
//  FOPopupAnimator.swift
//  Pods
//
//  Created by Daniel Krofchick on 2016-07-19.
//
//

class FOPopupAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting = false
    var popup: FOPopup!
    
    convenience init(presenting: Bool, popup: FOPopup) {
        self.init()
        
        self.presenting = presenting
        self.popup = popup
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            present(transitionContext)
        } else {
            dismiss(transitionContext)
        }
    }
    
    func present(_ transitionContext: UIViewControllerContextTransitioning) {
        if let
            from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        {
            let container = transitionContext.containerView
        
            container.addSubview(popup.background)
            container.addSubview(to.view)
            
            to.view.addGestureRecognizer(panRecognizer(popup))
            popup.background.addGestureRecognizer(dismisRecognizer(popup))
            popup.background.addGestureRecognizer(panRecognizer(popup))
            popup.background.frame = from.view.bounds
            popup.background.backgroundColor = UIColor(white: 0, alpha: 1)
            popup.background.alpha = 0
            
            let toS = to.preferredContentSize
            to.view.frame = CGRect(x: (from.view.frame.width - toS.width) / 2.0, y: from.view.frame.height, width: toS.width, height: toS.height)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                [weak self] in
                self?.popup.background.alpha = 0.5
                
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
    
    func dismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        if let
            from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        {
            let fromS = from.preferredContentSize
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                [weak self] in
                self?.popup.background.alpha = 0
                from.view.frame = CGRect(x: (to.view.frame.width - fromS.width) / 2.0, y: to.view.frame.height, width: fromS.width, height: fromS.height)
            }, completion: {
                [weak self] (finished) in
                self?.popup.background.removeFromSuperview()
                self?.popup.retainer = nil
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func dismisRecognizer(_ target: AnyObject?) -> UIGestureRecognizer {
        let recognizer = UITapGestureRecognizer(target: target, action: #selector(FOPopup.dismiss))
        
        if let target = target as? UIGestureRecognizerDelegate {
            recognizer.delegate = target
        }
        
        return recognizer
    }
    
    func panRecognizer(_ target: AnyObject?) -> UIGestureRecognizer {
        let recognizer = UIPanGestureRecognizer(target: target, action: #selector(FOPopup.pan))
        
        if let target = target as? UIGestureRecognizerDelegate {
            recognizer.delegate = target
        }
        
        return recognizer
    }
    
}
