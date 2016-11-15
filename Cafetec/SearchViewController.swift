//
//  SearchViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 14/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var foods = [PFObject]()
    
    var selectedFood: PFObject?
    
    //Declare it on top of the class
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet var notFound: UILabel!
    @IBOutlet var cartSize: UILabel!
    @IBOutlet var cartBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func refresh() {
        
        let search = searchTF.text!
        
        let queryName = PFQuery(className: "Food")
        queryName.whereKey("name", contains: search)
        
        let queryDescription = PFQuery(className: "Food")
        queryDescription.whereKey("description", contains: search)
        
        let query = PFQuery.orQuery(withSubqueries: [queryName, queryDescription])
        
        query.findObjectsInBackground { (objects, error) in
            
            //Remove it
            self.activityIndicator.stopAnimating()
            //Comment if you commented the ignoring of interaction
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if error != nil {
                
                print(error!)
                
            }else{
                
                
                if let foodsObjects = objects{
                    
                    if foodsObjects.count > 0 {
                        
                        for object in foodsObjects {
                            
                            if let food = object as PFObject! {
                                
                                self.foods.append(food)
                                
                            }
                            
                        }
                        
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        
                    }else{
                        
                        self.notFound.isHidden = false
                        
                    }
                    
                }
                
            }
            
        }
        
    }

    @IBAction func cartBtnPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "cartSegue", sender: self)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchTF.becomeFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.tableView.isHidden = true
        self.notFound.isHidden = true
        
        self.foods.removeAll()
        
        print("viewwillappear called")
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    /*
     
     Add father to view: "UITextFieldDelegate"
     (If made in MainStoryboard ctrl+drag the textField to view controller and set delegate)
     
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        refresh()
        
        //Display
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //Comment if you do not want to ignore interaction whilst
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        

        
        return true
        
    }
    
    //MARK: - Food Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        header.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Resultados"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchTableViewCell
        
        (self.foods[indexPath.row]["image"] as! PFFile).getDataInBackground { (data, error) in
            
            if let imageData = data {
                
                if let downloadedImage = UIImage(data: imageData) {
                    
                    cell.foodImage.image = downloadedImage
                    
                }
                
            }
            
        }
        
        let query = PFQuery(className: "Place")
        
        var placeString = ""
        
        /*query.getObjectInBackground(withId: (foods[indexPath.row]["placeId"] as! String)) { (object, error) in
            
            if error != nil {
                
                print(error!)
                
            }else{
                
                if let place = object {
                    
                    placeString = place["name"] as! String
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }*/
        
        query.whereKey("objectId", equalTo: (foods[indexPath.row]["placeId"] as! String))
        
        do{
           
            let place = try query.getFirstObject()
            
            placeString = place["name"] as! String
            
        }catch{
            
            print("Error getting place")
            
        }
        
        
        cell.placeName.text = placeString
        
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
            
        }else if segue.identifier == "cartSegue" {
            
            let vc = segue.destination as! CartViewController
            
            vc.performAnimations = true
            
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
