//
//  FOPopupController.swift
//  Pods
//
//  Created by Daniel Krofchick on 2016-07-18.
//
//

public class FOPopupController: UIViewController {
    
    var content: UIViewController!
    
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
