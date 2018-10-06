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
    
    let button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 1, alpha: 1)
        
        button.contentEdgeInsets = UIEdgeInsets(top: 40, left: 60, bottom: 40, right: 60)
        button.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont(name: "", size: 0.20)
        button.setTitle("Push Me", for: .normal)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc private func buttonTap() {
        present(FOPopup(content: FOContent()).content, animated: true, completion: nil)
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
    var views = [UIView]()
    private var dismissGesture: UITapGestureRecognizer?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        for _ in 0..<Int.random(in: 4...12) {
            appendView(height: CGFloat(Int.random(in: 20...200)))
        }
        
        dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTap))
        if let dismissGesture = dismissGesture {
            view.addGestureRecognizer(dismissGesture)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        view.backgroundColor = .clear
    }
    
    @objc func dismissTap() {
        dismiss(animated: true, completion: nil)
    }
    
    func appendView(height: CGFloat, color: UIColor = UIColor.random()) {
        let v = UIView()
        v.backgroundColor = color
        v.frame = CGRect(x: 0, y: 0, width: 0, height: height)
        view.addSubview(v)
        views.append(v)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var y = CGFloat(0)
        var maxW = CGFloat(0)
        let anchorIndex = Int.random(in: 0..<views.count)
        
        anchorPoints = [CGPoint]()
        anchorPoints?.append(CGPoint(x: 0, y: 0))
        
        for (i, v) in views.enumerated() {
            let width = v.frame.width == 0 ? CGFloat.random(in: 50...view.frame.width * 0.8) : v.frame.width
            v.frame = CGRect(x: (view.frame.width - width) / 2, y: y, width: width, height: v.frame.height)
            y += v.frame.height
            anchorPoints?.append(CGPoint(x: 0, y: y))
            
            maxW = max(maxW, width)
            
            if i == anchorIndex {
                startAnchorPoint = CGPoint(x: 0, y: y)
            }
        }
        
        preferredContentSize = CGSize(width: maxW, height: y)
    }
    
    func willSnapToPoint(_ point: CGPoint) -> CGPoint? {
        return point
    }
    
    func didPan(_ recognizer: UIPanGestureRecognizer) {
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIColor {
    
    class func random(
        red: CGFloat = CGFloat.random(in: 0...1),
        green: CGFloat = CGFloat.random(in: 0...1),
        blue: CGFloat = CGFloat.random(in: 0...1),
        alpha: CGFloat = CGFloat.random(in: 0.6...1)) -> UIColor
    {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
