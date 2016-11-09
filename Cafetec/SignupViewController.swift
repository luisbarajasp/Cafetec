//
//  SignupViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 08/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController {
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet var passwordTF: TabbedTextField!
    @IBOutlet var emailTF: TabbedTextField!
    @IBOutlet var matriculaTF: TabbedTextField!
    @IBOutlet var nameTF: TabbedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func returnToLogin(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signupPressed(_ sender: AnyObject) {
        
        if emailTF.text == "" || passwordTF.text == "" || nameTF.text == "" || matriculaTF.text == ""{
            
            createAlert(title: "Error", message: "Por favor ingresa tu nombre, matricula, correo y contraseña")
            
        }else if emailTF.text?.components(separatedBy: "@")[1] != "itesm.mx"{
            
            createAlert(title: "Error", message: "Por favor ingresa un correo del tec")
            
        }else{
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            // Sign Up
            
            let user = PFUser()
            
            user.username = emailTF.text
            user.email = emailTF.text
            user.password = passwordTF.text
            user["name"] = nameTF.text
            user["matricula"] = matriculaTF.text
            
            
            user.signUpInBackground(block: { (success, error) in
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if error != nil {
                    
                    let error = error as NSError?
                    
                    var displayErrorMessage = "Por favor intenta más tarde."
                    
                    if let errorMessage = error?.userInfo["error"] as? String{
                        
                        displayErrorMessage = errorMessage
                        
                    }
                    
                    self.createAlert(title: "Error de registro", message: displayErrorMessage)
                    
                    
                }else{
                    
                    print("User signed up")
                    
                    self.performSegue(withIdentifier: "accessGranted", sender: self)
                    
                }
                
            })
            
        }
        
    }

    
}


