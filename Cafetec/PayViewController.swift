//
//  PayViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 13/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class PayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var card: PFObject?
    
    @IBOutlet var collectionView: UICollectionView!
    
    var creditCardNumber = ""
    
    //Declare it on top of the class
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(PayViewController.refresh), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Display
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //Comment if you do not want to ignore interaction whilst
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        refresh()
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func refresh() {
        
        self.card = nil
        
        print("Refresh calles")

        
        let query = PFQuery(className: "Card")
        
        query.whereKey("userId", equalTo: PFUser.current()?.objectId as String!)
        
        query.getFirstObjectInBackground(block: { (object, error) in
            
            //Remove it
            self.activityIndicator.stopAnimating()
            //Comment if you commented the ignoring of interaction
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if let cardObject = object as PFObject! {
                        
                self.card = cardObject
                
            }
            
            self.collectionView.reloadData()
            
        })

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dismissPay(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        if card != nil {
            
            return 2
            
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellNew", for: indexPath) as UICollectionViewCell
            
            return cell
            
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PayCollectionViewCell
            
            cell.credtiCard.text = "···· " + (self.card?["number"] as! String!)
            
            cell.delete.addTarget(self, action: #selector(PayViewController.deleteCard), for: UIControlEvents.touchUpInside)
            
            return cell
            
        }
        
    }
    
    func deleteCard() {
        
        // Implement the deletion from stripe
        
        let query = PFQuery(className: "Card")
        
        print(self.card?.objectId as String!)
        
        //Display
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //Comment if you do not want to ignore interaction whilst
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        query.getObjectInBackground(withId: self.card?.objectId as String!, block: {(object, error) in
        
            if error != nil {
                
                print(error!)
                
            }else{
                
                if let cardObject = object as PFObject! {
                    
                    
                    cardObject.deleteInBackground(block: { (success, error) in
                        
                        if error != nil {
                            
                            print(error!)
                            
                        }else{
                            
                            if success {
                                
                                print("Card deleted successfully")
                                
                            }else{
                                
                                print("error")
                                
                            }
                            
                        }
                        
                    })
                    
                }
                
            }
            
            self.refresh()
        
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */

}
