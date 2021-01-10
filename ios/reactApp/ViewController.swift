//
//  ViewController.swift
//  reactApp
//
//  Created by Edmond Wu on 2021/1/8.
//

import UIKit
import React

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       
    }
    
    @IBAction func highScoreButtonTapped(sender : UIButton) {
        let jsCodeLocation:URL! = URL(string: "http://localhost:8081/index.bundle?platform=ios")
        let mockData:NSDictionary = ["scores":
            [
                ["name":"Alex", "value":"42"],
                ["name":"Joel", "value":"10"]
            ]
        ]

        let rootView = RCTRootView(
            bundleURL: jsCodeLocation,
            moduleName: "RNMyReactApp",
            initialProperties: mockData as [NSObject : AnyObject],
            launchOptions: nil
        )
        let vc = UIViewController()
        vc.view = rootView
        self.present(vc, animated: true, completion: nil)
    }


}

