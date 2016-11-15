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
    
    var creditCards = 0
    
    @IBOutlet var collectionView: UICollectionView!
    var creditCardNumber = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(PayViewController.refresh), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    func refresh() {
        
        print("Refresh calles")
        
        let query = PFUser.query()
        
        query?.getFirstObjectInBackground(block: { (object, error) in
            
            if let user = object as? PFUser {
                
                if user["card"] != nil {
                    
                    // User has credit card
                    
                    self.creditCards = 1
                    
                    self.creditCardNumber = user["card"] as! String!
                    
                }else{
                    
                    // User does not have credit card
                    
                    
                }
                
            }
            
        })
        
       self.collectionView.reloadData()

        
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
        return creditCards + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellNew", for: indexPath) as UICollectionViewCell
            
            return cell
            
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PayCollectionViewCell
            
            cell.credtiCard.text = "····" + self.creditCardNumber
            
            cell.delete.addTarget(self, action: #selector(PayViewController.deleteCard), for: UIControlEvents.touchUpInside)
            
            return cell
            
        }
        
    }
    
    func deleteCard() {
        
        // Implement the deletion from stripe
        
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
