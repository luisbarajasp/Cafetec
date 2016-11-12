//
//  SettingsViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 11/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var matriculaLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cartBtn: UIButton!
    @IBOutlet var cartSize: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = PFUser.current()?["name"] as! String?
        matriculaLabel.text = PFUser.current()?["matricula"] as! String?

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Resize tableview to the content height
        let point = self.tableView.frame.origin
        let size = CGSize(width: self.tableView.frame.width, height: self.tableView.contentSize.height)
        let frame = CGRect(origin: point, size: size)
        
        self.tableView.frame = frame
        
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
    
    @IBAction func showCartPressed(_ sender: Any) {
    }
    
    // MARK: - tableView methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 2
            
        }else{
            
            return 1
            
        }
        
    }
    
    /*func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            
            
            
        }
        
    }*/
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        return 40
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SettingsTableViewCell
            
        if (indexPath.section == 0 && indexPath.row == 0){
                
            cell.icon.image = UIImage(named: "fa-credit-card")
            cell.label.text = "Pago"
                
        }else if (indexPath.row == 1){
                
            cell.icon.image = UIImage(named: "Help")
            cell.label.text = "Ayuda"
                
        }else{
            
            cell.icon.image = UIImage(named: "Exit")
            cell.label.text = "Cerrar Sesión"
            
        }
            
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
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
