//
//  PlacesViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 09/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class PlacesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var placesCollectionView: UICollectionView!
    var placeSelected: PFObject?
    var places = [PFObject]()

    @IBOutlet var cartSize: UILabel!
    @IBOutlet var cartBtn: UIButton!
    
    @IBAction func cartBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "cartSegue", sender: self)
    }
    
    
    func refresh(){
        
        let query = PFQuery(className: "Place")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                
                print(error!)
                
            }else{
                
                
                if let placesObjects = objects{
                    
                    for object in placesObjects {
                        
                        if let place = object as PFObject! {
                            
                            self.places.append(place)
                            
                        }
                        
                    }
                    
                    self.placesCollectionView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        
        //UserDefaults.standard.set(2, forKey: "totalItems")

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
        // Check if there is an active Order for displaying the button
        
        let activeOrderObject = UserDefaults.standard.object(forKey: "activeOrder")
        let totalItemsObject = UserDefaults.standard.object(forKey: "totalItems")
        
        var totalItems = 0
        
        if let activeOrder = activeOrderObject as? String {
            
            if let itemsUnwrapped = totalItemsObject as? Int {
                
                if itemsUnwrapped > 0 {
                    
                    // User has active items
                    
                    totalItems = itemsUnwrapped
                    
                    self.cartSize.text = "\(totalItems)"
                    
                    self.cartBtn.isHidden = false
                    self.cartSize.isHidden = false
                    
                    print(activeOrder)
                    
                }else{
                    
                    // User has not active items
                    
                    
                    print(activeOrder)
                    
                    self.cartBtn.isHidden = true
                    self.cartSize.isHidden = true
                    
                }
                
                
            }else{
                
                // User has not active items
                
                self.cartBtn.isHidden = true
                self.cartSize.isHidden = true
                
            }
            
        }else{
            
            let query = PFQuery(className: "Order")
            
            query.whereKey("userId", equalTo: (PFUser.current()?.objectId!)! as String)
            query.whereKey("state", equalTo: 0)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if error != nil {
                    
                    print (error!)
                    
                }else{
                    
                    if let orders = objects {
                        
                        if orders.count > 0 {
                            
                            // User has an active order
                            
                            if let order = orders[0] as PFObject!{
                                
                                UserDefaults.standard.set(order.objectId as String!, forKey: "activeOrder")
                                
                                let query = PFQuery(className: "OrderItem")
                                
                                query.whereKey("orderId", equalTo: order.objectId! as String)
                                
                                query.findObjectsInBackground(block: { (objects, error) in
                                    
                                    if error != nil {
                                        
                                        print (error!)
                                        
                                    }else{
                                        
                                        if let items = objects {
                                            
                                            if items.count > 0 {
                                                
                                                // User has active items
                                                
                                                for item in items {
                                                    
                                                    totalItems += item["quantity"] as! Int
                                                    
                                                }
                                                
                                                UserDefaults.standard.set(totalItems, forKey: "totalItems")
                                                
                                                self.cartBtn.isHidden = false
                                                self.cartSize.isHidden = false
                                                
                                            }else{
                                                
                                                // User has not active items
                                                
                                                UserDefaults.standard.set(0, forKey: "totalItems")
                                                
                                                self.cartBtn.isHidden = true
                                                self.cartSize.isHidden = true
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                })
                                
                                
                                
                            }
                            
                        }else{
                            
                            // User does not have active order
                            
                            UserDefaults.standard.removeObject(forKey: "activeOrder")
                            UserDefaults.standard.removeObject(forKey: "totalItems")
                            
                            self.cartBtn.isHidden = true
                            self.cartSize.isHidden = true
                            
                        }
                        
                    }
                    
                    
                }
                
                
            })
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PlaceCollectionViewCell
        
        // Configure the cell
        cell.name.text = places[indexPath.row]["name"] as! String?
        cell.type.text = places[indexPath.row]["type"] as! String?
        
        (places[indexPath.row]["image"] as! PFFile).getDataInBackground { (data, error) in
            
            if let imageData = data {
                
                if let downloadedImage = UIImage(data: imageData) {
                    
                    cell.image.image = downloadedImage
                    
                }
                
            }
            
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "placeSelected" {
            
            let nc = segue.destination as! UINavigationController
            
            let vc = nc.viewControllers[0] as! PlaceViewController
            
            vc.place = self.placeSelected
            
            //self.navigationController?.pushViewController(vc, animated: true)
            
            self.present(nc, animated: true, completion: nil)
            
        }else if segue.identifier == "cartSegue" {
            
            let vc = segue.destination as! CartViewController
            
            vc.performAnimations = true
            
        }
        
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.placeSelected = places[indexPath.row]
        
        performSegue(withIdentifier: "placeSelected", sender: self)
        
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
