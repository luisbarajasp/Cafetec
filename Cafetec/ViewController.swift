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
    
    var activityIndicator = UIActivityIndicatorView()
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

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
            
            if emailTF.text == "" || passwordTF.text == "" {
                
                createAlert(title: "Error", message: "Por favor ingresa tu correo y contraseña")
                
            }else{
                
                activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                // Login Mode
                
                PFUser.logInWithUsername(inBackground: emailTF.text!, password: passwordTF.text!, block: { (user, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error != nil {
                        
                        let error = error as NSError?
                        
                        var displayErrorMessage = "Por favor intenta más tarde."
                        
                        if let errorMessage = error?.userInfo["error"] as? String{
                            
                            displayErrorMessage = errorMessage
                            
                        }
                        
                        self.createAlert(title: "Error de inico de sesión", message: displayErrorMessage)
                        
                    }else{
                        
                        print("Logged in")
                        
                        self.performSegue(withIdentifier: "accessGranted", sender: self)
                        
                    }
                    
                })
                
            }
    }

}

