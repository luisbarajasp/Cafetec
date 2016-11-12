//
//  PlaceViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 10/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class PlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var place: PFObject?
    
    var foods = [PFObject]()
    
    var selectedFood: PFObject?
    
    //Declare it on top of the class
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet var cartSize: UILabel!
    @IBOutlet var cartBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var placeType: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var foodTable: UITableView!
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*override var prefersStatusBarHidden: Bool {
        return true
    }*/
    @IBAction func cartBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "cartSegue", sender: self)
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func refresh() {
        
        //Display
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //Comment if you do not want to ignore interaction whilst
        UIApplication.shared.beginIgnoringInteractionEvents()

        
        let query = PFQuery(className: "Food")
        
        query.whereKey("placeId", equalTo: place!.objectId!)
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                
                print(error!)
                self.createAlert(title: "Error", message: "Sucedió un error por favor intenta más tarde.")
                
            }else{
                
                if let foodsObjects = objects {
                    
                    for food in foodsObjects {
                        
                        self.foods.append(food)
                        
                    }
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
            //Remove it
            self.activityIndicator.stopAnimating()
            //Comment if you commented the ignoring of interaction
            UIApplication.shared.endIgnoringInteractionEvents()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        refresh()
        
        if let placeUnwrapped = place {
            
            print(placeUnwrapped)
            
            (placeUnwrapped["image"] as! PFFile).getDataInBackground { (data, error) in
                
                if let imageData = data {
                    
                    if let downloadedImage = UIImage(data: imageData) {
                        
                        self.placeImage.image = downloadedImage
                        
                    }
                    
                }
                
            }
            
            placeName.text = placeUnwrapped["name"] as! String?
            placeType.text = placeUnwrapped["type"] as! String?
            timeLabel.text = "~30 min"
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        // Deselect previous row when returning to view
        
        let indexPath = self.tableView.indexPathForSelectedRow
        
        if ((indexPath) != nil) {
            
            self.tableView.deselectRow(at: indexPath!, animated: true)
            
        }
        
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
    
    //MARK: - Food Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FoodTableViewCell
        
        (self.foods[indexPath.row]["image"] as! PFFile).getDataInBackground { (data, error) in
            
            if let imageData = data {
                
                if let downloadedImage = UIImage(data: imageData) {
                    
                    cell.foodImage.image = downloadedImage
                    
                }
                
            }
            
        }
        
        cell.foodName.text = foods[indexPath.row]["name"] as! String?
        cell.foodDescription.text = foods[indexPath.row]["description"] as! String?
        var price: Float = 0
        
        if let priceU = foods[indexPath.row]["price"] as! Float? {
            
            price = priceU
            
        }
        
        let twoDecimalPlaces = String(format: "%.2f", price)
        
        cell.foodPrice.text =  "$\(twoDecimalPlaces)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedFood = foods[indexPath.row]
        
        performSegue(withIdentifier: "foodSelected", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "foodSelected" {
            
            let vc = segue.destination as! FoodViewController
            
            vc.food = self.selectedFood
            
            //self.navigationController?.pushViewController(vc, animated: true)
            
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
