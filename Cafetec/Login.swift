//
//  ViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 28/10/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let testObject = PFObject(className: "Place")
        testObject["name"] = "Subway"
        testObject.saveInBackground { (success, error) in
            
            if error != nil {
                
                print(error)
                
            }else{
                
                if success {
                    
                    print("Yeah")
                    
                }
                
            }
            
        }*/
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginPressed(_ sender: AnyObject) {
    }
    @IBAction func signupPressed(_ sender: AnyObject) {
    }

}

