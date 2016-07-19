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
        let content = UIViewController()
        content.view.backgroundColor = UIColor.orangeColor()
        content.preferredContentSize = CGSize(width: 200, height: 100)
        
        let popup = FOPopupController(content: content)
        presentViewController(popup, animated: false, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        button.sizeToFit()
        button.center = view.center
    }


}

