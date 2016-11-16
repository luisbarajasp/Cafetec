//
//  SignupViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 08/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
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

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            signupPressed(self)
        }
        return false // We do not want UITextField to insert line-breaks.
        
    }
    
    
    @IBAction func returnToLogin(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
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
            
            let acl = PFACL()
            acl.getPublicWriteAccess = true
            acl.getPublicReadAccess = true
            //acl.setWriteAccess(true, for: PFUser.current()!)
            user.acl = acl
            
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


