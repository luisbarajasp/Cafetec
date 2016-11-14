//
//  NewCardViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 13/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit

class NewCardViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var date: UITextField!
    @IBOutlet var cvc: UITextField!
    @IBOutlet var number: UITextField!
    @IBOutlet var dynamicView: UIView!
    
    //Declare it on top of the class
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        date.delegate = self
        cvc.delegate = self
        number.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        number.becomeFirstResponder()
        
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
            self.submitNewCard()
        }
        return false // We do not want UITextField to insert line-breaks.
        
    }
    
    func submitNewCard() {
        self.view.endEditing(true)
        
        //Display
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //Comment if you do not want to ignore interaction whilst
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(NewCardViewController.removeActivityIndicator), userInfo: nil, repeats: false)

        
        
    }
    
    func removeActivityIndicator() {
        
        // In Navigation controller used to let it know to parent to reload data
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        //Remove it
        self.activityIndicator.stopAnimating()
        //Comment if you commented the ignoring of interaction
        UIApplication.shared.endIgnoringInteractionEvents()
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - Textfield validation
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // We ignore any change that doesn't add characters to the text field.
        // These changes are things like character deletions and cuts, as well
        // as moving the insertion point.
        //
        // We still return true to allow the change to take place.
        if string.characters.count == 0 {
            return true
        }
        
        // Check to see if the text field's contents still fit the constraints
        // with the new content added to it.
        // If the contents still fit the constraints, allow the change
        // by returning true; otherwise disallow the change by returning false.
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
            
        // Allow only digits in this field,
        // and limit its contents to a maximum of 16 characters.
        case number:
            return prospectiveText.isNumeric() &&
                prospectiveText.characters.count <= 16
            
        // Allow only digits in this field,
        // and limit its contents to a maximum of 3 characters.
        case cvc:
            return prospectiveText.isNumeric() &&
                prospectiveText.characters.count <= 3
        
        // Allow only digits in this field,
        // and limit its contents to a maximum of 4 characters.
        case date:
            return prospectiveText.isNumeric() &&
                prospectiveText.characters.count <= 4
            
            // Do not put constraints on any other text field in this view
        // that uses this class as its delegate.
        default:
            return true
        }
        
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
