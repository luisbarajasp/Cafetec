//
//  CartViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 12/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var items = [PFObject]()
    
    var totalPrice: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let orderObject = UserDefaults.standard.object(forKey: "activeOrder")
        
        if let order = orderObject as? String {
            
            let query = PFQuery(className: "Order")
            
            query.getObjectInBackground(withId: order, block: { (object, error) in
                
                if error != nil {
                    
                    print(error!)
                    
                }else{
                    
                    if let order = object {
                        
                        let query = PFQuery(className: "Place")
                        
                        query.getObjectInBackground(withId: order["placeId"] as! String, block: { (object, error) in
                            
                            if let place = object {
                                
                                (place["image"] as! PFFile).getDataInBackground { (data, error) in
                                    
                                    if let imageData = data {
                                        
                                        if let downloadedImage = UIImage(data: imageData) {
                                            
                                            self.placeImage.image = downloadedImage
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                self.placeName.text = place["name"] as! String?
                                
                            }
                            
                            
                        })
                        
                    }
                    
                }
                
            })
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        
        let orderObject = UserDefaults.standard.object(forKey: "activeOrder")
        
        if let order = orderObject as? String {
            
            let query = PFQuery(className: "OrderItem")
            
            query.whereKey("orderId", equalTo: order)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if error != nil {
                    
                    print(error!)
                    
                }else{
                    
                    if let items = objects {
                        
                        for item in items {
                            
                            self.items.append(item)
                            
                        }
                        
                    }
                    
                }
                
                self.tableView.reloadData()
                
            })
            
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
    }
    
    @IBAction func pay(_ sender: Any) {
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return items.count
            
        }else{
            
            return 1
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CartItemTableViewCell
            
            cell.quantityLabel.text = "\(items[indexPath.row]["quantity"] as! Int)"
            
            let query = PFQuery(className: "Food")
            
            query.getObjectInBackground(withId: (items[indexPath.row]["foodId"] as? String!)!, block: { (object, error) in
                
                if error != nil {
                    
                    print(error!)
                    
                }else{
                    
                    if let food = object {
                        
                        cell.nameLabel.text = food["name"] as! String!
                        
                        let twoDecimalPlaces = String(format: "%.2f", (food["price"] as! Float!)!)
                        
                        cell.priceLabel.text = "$"+twoDecimalPlaces
                        
                    }
                    
                }
                
            })
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellTotal", for: indexPath) as! CartTotalTableViewCell
            
            var total: Float = 0
            
            for item in items {
                
                total += item["price"] as! Float
                
            }
            print(total)
            
            let twoDecimalPlaces = String(format: "%.2f", total)
            
            print(twoDecimalPlaces)
            
            cell.totalPriceLabel.text = "$"+twoDecimalPlaces
            
            self.totalPrice = total
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
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
