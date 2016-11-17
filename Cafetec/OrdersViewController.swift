//
//  OrdersViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 14/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class OrdersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var cartSize: UILabel!
    @IBOutlet var cartBtn: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var notFound: UILabel!
    
    //Declare it on top of the class
    var activityIndicator = UIActivityIndicatorView()
    
    var orderSelected: PFObject?
    
    var orders = [PFObject]()
    
    func refresh(){

        //Display
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //Comment if you do not want to ignore interaction whilst
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.orders.removeAll()

        
        let queryTwo = PFQuery(className: "Order")
        
        queryTwo.whereKey("state", equalTo: 2)
        
        let queryOne = PFQuery(className: "Order")
        
        queryOne.whereKey("state", equalTo: 1)
        
        
        let query = PFQuery.orQuery(withSubqueries: [queryOne, queryTwo])
        
        query.whereKey("userId", equalTo: (PFUser.current()?.objectId)! as String!)
        
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            
            //Remove it
            self.activityIndicator.stopAnimating()
            //Comment if you commented the ignoring of interaction
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if error != nil {
                
                print(error!)
                
            }else{
                
                
                if let orderObjects = objects{
                    
                    if orderObjects.count > 0 {
                        
                        for object in orderObjects {
                            
                            if let order = object as PFObject! {
                                
                                self.orders.append(order)
                                
                            }
                            
                        }
                        
                        print(self.orders)
                        
                        self.collectionView.reloadData()
                        
                        
                    }else{
                        
                        self.notFound.isHidden = false
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        // Check if there is an active Order for displaying the button
        
        refresh()
        
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
                                                self.cartSize.text = "\(totalItems)"
                                                
                                                self.cartBtn.isHidden = false
                                                self.cartSize.isHidden = false
                                                
                                            }else{
                                                
                                                // User has not active items
                                                
                                                UserDefaults.standard.set(0, forKey: "totalItems")
                                                self.cartSize.text = "\(totalItems)"
                                                
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
    
    @IBAction func cartBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "cartSegue", sender: self)
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
        
        return orders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! OrderCollectionViewCell
        
        let query = PFQuery(className: "Place")
        
        query.whereKey("objectId", equalTo: orders[indexPath.row]["placeId"] as! String)
        
        do{
            
            let place = try query.getFirstObject()
            
            cell.placeName.text = place["name"] as? String
            
            let twoDecimalPlaces = String(format: "%.2f", orders[indexPath.row]["price"] as! Float)
            
            cell.orderPrice.text =  "$\(twoDecimalPlaces)"
            
            (place["image"] as! PFFile).getDataInBackground { (data, error) in
                
                if let imageData = data {
                    
                    if let downloadedImage = UIImage(data: imageData) {
                        
                        cell.placeImage.image = downloadedImage
                        
                    }
                    
                }
                
            }
            
            var dateOrder = ""
            
            let updatedAt = orders[indexPath.row].updatedAt
            
            if updatedAt != nil {
                
                // change to a readable time format and change to local time zone
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/YY"
                dateFormatter.timeZone = NSTimeZone.local
                dateOrder = dateFormatter.string(from: updatedAt!)
                
            }
            
            cell.orderDate.text = dateOrder
            
            let state = orders[indexPath.row]["state"] as! Int
            
            if state == 1 {
                
                cell.stateColor.backgroundColor = UIColor(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)
                cell.stateStatus.textColor = UIColor(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)
                cell.stateStatus.text = "Por entregar"
                
            }else if state == 2{
                
                cell.stateColor.backgroundColor = UIColor(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
                cell.stateStatus.textColor = UIColor(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
                
                var timeStamp = ""
                
                let deliveredAt = orders[indexPath.row]["deliveredAt"]
                
                if deliveredAt != nil {
                    
                    // change to a readable time format and change to local time zone
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    dateFormatter.timeZone = NSTimeZone.local
                    timeStamp = dateFormatter.string(from: deliveredAt! as! Date)
                    
                }
                
                cell.stateStatus.text = "Entregada " + timeStamp
                
            }else{
                
                cell.stateColor.backgroundColor = UIColor(red: 0.9607843137, green: 0.3176470588, blue: 0.3725490196, alpha: 1)
                cell.stateStatus.textColor = UIColor(red: 0.9607843137, green: 0.3176470588, blue: 0.3725490196, alpha: 1)
                
                cell.stateStatus.text = "Cancelada"
                
            }
            
            
            
        }catch{
            
            print("Failed to get the place")
            
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "orderSelected" {
            
            let vc = segue.destination as! OrderViewController
            
            vc.orderSelected = self.orderSelected
            
            vc.showBack = true
            
            //self.navigationController?.pushViewController(vc, animated: true)
            
        }else if segue.identifier == "cartSegue" {
            
            let vc = segue.destination as! CartViewController
            
            vc.performAnimations = true
            
        }
        
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.orderSelected = orders[indexPath.row]
        
        performSegue(withIdentifier: "orderSelected", sender: self)
        
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
