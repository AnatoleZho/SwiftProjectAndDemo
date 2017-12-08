//
//  ViewController.swift
//  SwiftProject
//
//  Created by EastElsoft on 2017/12/7.
//  Copyright © 2017年 EastElsoft. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customVC = CustomViewController.init(nibName: "CustomViewController", bundle: nil)
        let ocVC = OCViewController.init(nibName: "OCViewController", bundle: nil)
        
        let progress = MBProgressHUD.hide(for: self.view, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

