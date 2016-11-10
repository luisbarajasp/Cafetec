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
    var places = [PFObject]()

    /*@IBAction func logout(_ sender: Any) {
        
        PFUser.logOut()
        
        performSegue(withIdentifier: "logoutSegue", sender: self)
        
    }*/
    
    func refresh(){
        
        let query = PFQuery(className: "Place")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                
                print(error!)
                
            }else{
                
                
                if let placesObjects = objects{
                    
                    for object in placesObjects {
                        
                        if let place = object as PFObject! {
                            
                            print("Hello")
                            
                            self.places.append(place)
                            
                            print(self.places.count)
                            
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

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
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
    
    // MARK: UICollectionViewDelegate
    
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
