//
//  ViewController.swift
//  FOPopup
//
//  Created by Daniel Krofchick on 07/18/2016.
//  Copyright (c) 2016 Daniel Krofchick. All rights reserved.
//

import UIKit
import FOPopup

class ViewController: UIViewController {
    
    let button = UIButton(type: .System)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 1, alpha: 1)
        
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.redColor().CGColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.setTitle("Push Me", forState: .Normal)
        button.addTarget(self, action: #selector(buttonTap), forControlEvents: .TouchUpInside)
        view.addSubview(button)
    }
    
    func buttonTap() {
        presentViewController(FOPopup(content: FOContent()).content, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        button.sizeToFit()
        button.center = view.center
    }
    
}

class FOContent: UIViewController, FOPopupProtocol {
    
    var anchorPoints: [CGPoint]?
    var startAnchorPoint: CGPoint?
    weak var popup: FOPopup?
    
    var views = [UIView]()
    var preferredWidth = CGFloat(200)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let heights: [CGFloat] = [200, 100]
        
        for h in heights {
            v(h)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        view.backgroundColor = UIColor.orangeColor()
    }
    
    func v(height: CGFloat, color: UIColor = UIColor.random()) -> UIView {
        let v = UIView()
        v.backgroundColor = color
        v.frame = CGRect(x: 0, y: 0, width: preferredWidth, height: height)
        view.addSubview(v)
        views.append(v)
        
        return v
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var y = CGFloat(0)
        
        anchorPoints = [CGPoint]()
        anchorPoints?.append(CGPoint(x: 0, y: 0))
        
        for (index, v) in views.enumerate() {
            v.frame = CGRect(x: (view.frame.width - preferredWidth) / 2, y: y, width: preferredWidth, height: v.frame.height)
            y += v.frame.height
            anchorPoints?.append(CGPoint(x: 0, y: y))
            
            if index == 0 {
                startAnchorPoint = CGPoint(x: 0, y: y)
            }
        }
        
        preferredContentSize = CGSize(width: preferredWidth, height: y)
    }
    
    func willSnapToPoint(point: CGPoint) -> CGPoint? {
        return point
    }
    
    func didPan(recognizer: UIPanGestureRecognizer) {
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIColor {
    
    class func random(red: CGFloat = randomF(), green: CGFloat = randomF(), blue: CGFloat = randomF(), alpha: CGFloat = randomF()) -> UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}

private func randomF() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
}
