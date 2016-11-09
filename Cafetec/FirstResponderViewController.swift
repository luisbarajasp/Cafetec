//
//  FirstResponderViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 08/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class FirstResponderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.current() != nil {
            
            performSegue(withIdentifier: "accessGranted", sender: self)
            
        }else{
            
            performSegue(withIdentifier: "credentialsNeeded", sender: self)
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
