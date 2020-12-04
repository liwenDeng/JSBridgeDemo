//
//  ViewController.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/7/3.
//  Copyright © 2020 dsjk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func jump(_ sender: Any) {
      let webVC = WebViewController("http://127.0.0.1:3000/index.html")
//        let webVC = WebViewController("http://127.0.0.1:8080/pages/index.html")
        navigationController?.pushViewController(webVC, animated: true)
    }
    
}

