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
    
    @IBOutlet var dynamicView: UIView!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var items = [PFObject]()
    
    var totalPrice: Float = 0
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
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
        
        refresh()
        
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
        
        //Resize tableview to the content height
        let point = self.tableView.frame.origin
        let size = CGSize(width: self.tableView.frame.width, height: self.tableView.contentSize.height)
        let frame = CGRect(origin: point, size: size)
        
        self.tableView.frame = frame
        
        //Animations
        self.placeName.alpha = 1
        
        //Variables to save the initial values
        let width : CGFloat = dynamicView.frame.width
        let height : CGFloat = dynamicView.frame.height
        let x : CGFloat = dynamicView.frame.minX
        let y : CGFloat = dynamicView.frame.minY
        
        UIView.animate(withDuration: 0.5, animations: {
            
            //self.placeName.alpha = 1
            
            self.dynamicView.frame = CGRect(x: x, y: y - 407, width: width, height: height)
            
        })
        
    }
    
    @IBAction func pay(_ sender: Any) {
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
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
            
        }else if indexPath.section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellTotal", for: indexPath) as! CartTotalTableViewCell
            
            var total: Float = 0
            
            for item in items {
                
                total += item["price"] as! Float
                
            }
            
            let twoDecimalPlaces = String(format: "%.2f", total)
            
            cell.totalPriceLabel.text = "$"+twoDecimalPlaces
            
            self.totalPrice = total
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellPay", for: indexPath) as! CartPayTableViewCell
            
            if PFUser.current()!["customerId"] != nil {
                
                // User has credit card
                
            }else{
                
                // User does not have credit card
                
                cell.cardLabel.text = "No tienes tarjeta"
                cell.button.setTitle("NUEVA TARJETA", for: [])
                
            }
            
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0{
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            //Declare it on top of the class
            var activityIndicator = UIActivityIndicatorView()
            
            //Display
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            //Comment if you do not want to ignore interaction whilst
            UIApplication.shared.beginIgnoringInteractionEvents()

            
            let item = self.items[indexPath.row]
            
            let query = PFQuery(className: "OrderItem")
            
            query.getObjectInBackground(withId: (item.objectId as String!)!, block: { (object, error) in
                
                //Remove it
                activityIndicator.stopAnimating()
                //Comment if you commented the ignoring of interaction
                UIApplication.shared.endIgnoringInteractionEvents()
                
                if error != nil {
                    
                    print (error!)
                    
                    self.createAlert(title: "Error", message: "No se pudo editar el pedido. Intenta más tarde.")
                    
                }else{
                    
                    if let orderItem = object {
                        
                        let totalItemsObject = UserDefaults.standard.object(forKey: "totalItems")
                        
                        if let itemsUnwrapped = totalItemsObject as? Int {
                            
                            let totalItems = itemsUnwrapped - (orderItem["quantity"] as! Int)
                            
                            UserDefaults.standard.set(totalItems, forKey: "totalItems")
                            
                        }
                        
                        orderItem.deleteInBackground()
                        
                        DispatchQueue.main.async{
                            tableView.reloadData()
                        }
                        
                        self.createAlert(title: "Eliminado", message: "Se eliminó el alimento con éxito.")

                    }
                    
                }
                
            })
            
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
