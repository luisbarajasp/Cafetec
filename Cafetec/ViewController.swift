//
//  ViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 28/10/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var signInBtn: UIButton!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    var name = ""
    var i = 0
    var loaded = false
    
    var activityIndicator = UIActivityIndicatorView()
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    /* Set ascending tags to the text fields */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTage = textField.tag+1;
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
            loginPressed(self)
        }
        return false // We do not want UITextField to insert line-breaks.
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func accessGranted() {
        
        performSegue(withIdentifier: "accessGranted", sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.current() != nil {
            
            //Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.accessGranted), userInfo: nil, repeats: true)
            performSegue(withIdentifier: "accessGranted", sender: self)
            
        }else if !loaded{
            
            UIView.animate(withDuration: 1.5, animations: {
                
                self.emailTF.center = CGPoint(x: self.emailTF.center.x, y: self.emailTF.center.y - 300)
                self.passwordTF.center = CGPoint(x: self.passwordTF.center.x, y: self.passwordTF.center.y - 300)
                self.signInBtn.center = CGPoint(x: self.signInBtn.center.x, y: self.signInBtn.center.y - 300)
                self.signUpBtn.center = CGPoint(x: self.signUpBtn.center.x, y: self.signUpBtn.center.y - 300)
                
            })
            
            loaded = true
            
        }
        
        
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

