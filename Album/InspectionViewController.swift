//
//  InspectionViewController.swift
//  Album
//
//  Created by Mister on 16/4/25.
//  Copyright © 2016年 aimobier. All rights reserved.
//

import UIKit

class InspectionViewController: UIViewController,PhotoAuthProtocol {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.AuthorizationStatus { (auth) in
            
            let identifier =  auth ? "yes" : "no"
            
            self.performSegueWithIdentifier(identifier, sender: nil)
        }
    }
}

