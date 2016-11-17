//
//  FoodViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 10/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class FoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var food: PFObject?
    var countNumber = 1
    var totalpay: Float = 0
    var foodPrice: Float = 0
    var foodOptions = [String : Array<String>]()
    var radioButtonControllers = [SSRadioButtonsController]()
    var buttonsArray = [UIButton]()
    
    //Declare it on top of the class
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func backPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBOutlet var foodImage: UIImageView!
    @IBOutlet var foodName: UILabel!
    @IBOutlet var foodDescription: UILabel!
    @IBOutlet var optionsTable: UITableView!
    
    @IBOutlet var toPay: UILabel!
    @IBOutlet var confirmOrderBtn: UIButton!
    @IBOutlet var count: UIButton!
    @IBOutlet var dynamicView: UIView!
    
    func defineOptions() {
        
        var dictionary = [String : Array<String>]()
        
        dictionary = ["Especialidad" : ["Pastor","Milanesa","Pollo"], "Bebida" : ["Agua fresca", "Refresco"]]
        
        food?["options"] = dictionary
        food?.saveInBackground(block: { (success, error) in
            
            if success {
                print("Saved")
            }else{
                print("Error")
            }
            
            
        })
        
        optionsTable.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let foodUnwrapped = food {
            
            print(foodUnwrapped)
            
            (foodUnwrapped["image"] as! PFFile).getDataInBackground { (data, error) in
                
                if let imageData = data {
                    
                    if let downloadedImage = UIImage(data: imageData) {
                        
                        self.foodImage.image = downloadedImage
                        
                    }
                    
                }
                
            }
            
            //defineOptions()
            
            foodOptions = (food?["options"] as! Dictionary<String, Array<String>>)
            
            print(foodOptions.count as Int)
            
            optionsTable.separatorColor = UIColor.clear
            
            foodName.text = foodUnwrapped["name"] as! String?
            foodDescription.text = foodUnwrapped["description"] as! String?
            
            foodPrice = foodUnwrapped["price"] as! Float
            
            totalpay = foodPrice
            
            let twoDecimalPlaces = String(format: "%.2f", totalpay)
            
            toPay.text = "$"+twoDecimalPlaces
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fillButtonsArray()
        
        //Resize tableview to the content height
        let point = self.optionsTable.frame.origin
        let size = CGSize(width: self.optionsTable.frame.width, height: self.optionsTable.contentSize.height)
        let frame = CGRect(origin: point, size: size)
        
        self.optionsTable.frame = frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lessCount(_ sender: Any) {
        if self.countNumber > 1 {
            self.countNumber -= 1
            
            count.setTitle("\(self.countNumber)", for: [])
            
            confirmOrderBtn.setTitle("\(self.countNumber)", for: [])
            
            self.totalpay -= self.foodPrice
            
            let twoDecimalPlaces = String(format: "%.2f", self.totalpay)
            
            self.toPay.text = twoDecimalPlaces
        }
    }
    @IBAction func moreCount(_ sender: Any) {
        if countNumber < 9 {
            self.countNumber += 1
            
            count.setTitle("\(self.countNumber)", for: [])
            
            confirmOrderBtn.setTitle("\(self.countNumber)", for: [])
            
            self.totalpay += self.foodPrice
            
            let twoDecimalPlaces = String(format: "%.2f", self.totalpay)
            
            self.toPay.text = "$"+twoDecimalPlaces
        }
    }
    @IBAction func orderConfirmed(_ sender: Any) {
        
        let query = PFQuery(className: "Order")
        
        query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
        query.whereKey("state", equalTo: 0)
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                
                print(error!)
                
            }else{
                
                if let orders = objects {
                    
                    if orders.count > 0 {
                        
                        // User has an active order
                        
                        if let order = orders[0] as PFObject!{
                            
                            let orderPlace = order["placeId"] as! String
                            
                            let foodPlace = self.food?["placeId"] as! String
                        
                            if orderPlace == foodPlace {
                            
                                // The food is from the same place
                                
                                let orderItem = PFObject(className: "OrderItem")
                                
                                //Set quantity
                                orderItem["quantity"] = self.countNumber
                                //Set total price
                                orderItem["price"] = self.totalpay
                                //Set the options selected
                                let foodOptions = self.food?["options"] as! Dictionary<String, Array<String>>
                                let keys = Array(foodOptions.keys)
                                var dictionary = [String: String]()
                                var i = 0
                                for key in keys {
                                    dictionary[key] = self.radioButtonControllers[i].selectedButton()?.title(for: [])! as String!
                                    i += 1
                                }
                                print(dictionary)
                                orderItem["options"] = dictionary
                                //Set the order
                                orderItem["orderId"] = order.objectId
                                //Set the food
                                orderItem["foodId"] = self.food?.objectId
                                
                                let acl = PFACL()
                                acl.getPublicWriteAccess = true
                                acl.getPublicReadAccess = true
                                acl.setWriteAccess(true, for: PFUser.current()!)
                                orderItem.acl = acl
                                
                                //Display
                                self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                                self.activityIndicator.center = self.view.center
                                self.activityIndicator.hidesWhenStopped = true
                                self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                                self.view.addSubview(self.activityIndicator)
                                self.activityIndicator.startAnimating()
                                //Comment if you do not want to ignore interaction whilst
                                UIApplication.shared.beginIgnoringInteractionEvents()
                                
                                orderItem.saveInBackground { (success, error) -> Void in
                                    
                                    //Remove it
                                    self.activityIndicator.stopAnimating()
                                    //Comment if you commented the ignoring of interaction
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    
                                    // added test for success 11th July 2016
                                    
                                    if success {
                                        
                                        print("Object has been saved.")
                                        
                                        let totalItemsObject = UserDefaults.standard.object(forKey: "totalItems")
                                        
                                        if let itemsUnwrapped = totalItemsObject as? Int {
                                            
                                            let totalItems = itemsUnwrapped + self.countNumber
                                            
                                            UserDefaults.standard.set(totalItems, forKey: "totalItems")
                                            
                                            
                                            print("OrderItem has been saved.")
                                            
                                            let oldPrice = order["price"] as! Float!
                                            
                                            let newPrice = oldPrice! + self.totalpay
                                            
                                            let query = PFQuery(className: "Order")
                                            
                                            query.getObjectInBackground(withId: order.objectId as String!, block: { (object, error) in
                                                
                                                if let orderObject = object {
                                                    
                                                    orderObject["price"] = newPrice
                                                    
                                                    orderObject.saveInBackground(block: { (success, error) in
                                                        
                                                        if error != nil {
                                                            
                                                            print(error!)
                                                            
                                                        }else{
                                                            
                                                            
                                                            if success {
                                                                
                                                                print("Order update price")
                                                                
                                                            }else{
                                                                
                                                                print("error")
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    })
                                                    
                                                }
                                                
                                            })
                                            
                                            order["price"] = newPrice
                                        }
                                        
                                    } else {
                                        
                                        if error != nil {
                                            
                                            print (error!)
                                            
                                        } else {
                                            
                                            print ("Error")
                                        }
                                        
                                    }
                                    
                                }
                                
                                _ = self.navigationController?.popViewController(animated: true)
                                
                            }else{
                            
                                // The food is from another place
                                
                                let alert = UIAlertController(title: "Alerta", message: "Tienes una orden de otro establecimiento ¿qué deseas hacer?", preferredStyle: UIAlertControllerStyle.alert)
                                
                                
                                alert.addAction(UIAlertAction(title: "Reemplazar", style: UIAlertActionStyle.default, handler: { (action) in
                                    
                                    //Display
                                    self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                                    self.activityIndicator.center = self.view.center
                                    self.activityIndicator.hidesWhenStopped = true
                                    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                                    self.view.addSubview(self.activityIndicator)
                                    self.activityIndicator.startAnimating()
                                    //Comment if you do not want to ignore interaction whilst
                                    UIApplication.shared.beginIgnoringInteractionEvents()
                                    
                                    var query = PFQuery(className: "OrderItem")
                                    
                                    query.whereKey("orderId", equalTo: order.objectId as String!)
                                    
                                    query.findObjectsInBackground(block: { (objects, error) in
                                        
                                        if let items = objects as [PFObject]! {
                                            
                                            for item in items {
                                                
                                                item.deleteInBackground()
                                                
                                            }
                                            
                                        }
                                        
                                    })
                                    
                                    query = PFQuery(className: "Order")
                                    
                                    query.getObjectInBackground(withId: order.objectId!, block: { (object, error) in
                                        
                                        if error != nil{
                                            
                                            print(error!)
                                            
                                        }else{
                                            
                                            if let orderObject = object as PFObject! {
                                                
                                                
                                                orderObject.deleteInBackground()
                                                
                                            }
                                            
                                        }
                                        
                                    })
                                    
                                    let newOrder = PFObject(className: "Order")
                                    
                                    newOrder["state"] = 0
                                    newOrder["price"] = 0
                                    newOrder["placeId"] = self.food?["placeId"]
                                    newOrder["userId"] = PFUser.current()?.objectId!
                                    
                                    let acl = PFACL()
                                    acl.getPublicWriteAccess = true
                                    acl.getPublicReadAccess = true
                                    acl.setWriteAccess(true, for: PFUser.current()!)
                                    newOrder.acl = acl
                                    
                                    newOrder.saveInBackground(block: { (success, error) in
                                        
                                        if error != nil {
                                            
                                            print(error!)
                                            
                                        }else{
                                            
                                            
                                            if success {
                                                
                                                
                                                let orderItem = PFObject(className: "OrderItem")
                                                
                                                //Set quantity
                                                orderItem["quantity"] = self.countNumber
                                                //Set total price
                                                orderItem["price"] = self.totalpay
                                                //Set the options selected
                                                let foodOptions = self.food?["options"] as! Dictionary<String, Array<String>>
                                                let keys = Array(foodOptions.keys)
                                                var dictionary = [String: String]()
                                                var i = 0
                                                for key in keys {
                                                    dictionary[key] = self.radioButtonControllers[i].selectedButton()?.title(for: [])! as String!
                                                    i += 1
                                                }
                                                print(dictionary)
                                                orderItem["options"] = dictionary
                                                //Set the order
                                                orderItem["orderId"] = newOrder.objectId
                                                //Set the food
                                                orderItem["foodId"] = self.food?.objectId
                                                
                                                let acl = PFACL()
                                                acl.getPublicWriteAccess = true
                                                acl.getPublicReadAccess = true
                                                acl.setWriteAccess(true, for: PFUser.current()!)
                                                orderItem.acl = acl
                                                
                                                orderItem.saveInBackground { (success, error) -> Void in
                                                    
                                                    //Remove it
                                                    self.activityIndicator.stopAnimating()
                                                    //Comment if you commented the ignoring of interaction
                                                    UIApplication.shared.endIgnoringInteractionEvents()
                                                    
                                                    // added test for success 11th July 2016
                                                    
                                                    if success {
                                                        
                                                        print("OrderItem has been saved.")
                                                        
                                                        let newPrice = self.totalpay
                                                        
                                                        let query = PFQuery(className: "Order")
                                                        
                                                        query.getObjectInBackground(withId: newOrder.objectId as String!, block: { (object, error) in
                                                            
                                                            if let orderObject = object {
                                                                
                                                                orderObject["price"] = self.totalpay
                                                                
                                                                orderObject.saveInBackground(block: { (success, error) in
                                                                    
                                                                    if error != nil {
                                                                        
                                                                        print(error!)
                                                                        
                                                                    }else{
                                                                        
                                                                        
                                                                        if success {
                                                                            
                                                                            print("Order update price")
                                                                            
                                                                        }else{
                                                                            
                                                                            print("error")
                                                                            
                                                                        }
                                                                        
                                                                    }
                                                                    
                                                                })
                                                                
                                                            }
                                                            
                                                        })
                                                        
                                                        newOrder["price"] = newPrice
                                                        
                                                        UserDefaults.standard.set(newOrder.objectId as String!, forKey: "activeOrder")
                                                        UserDefaults.standard.set(self.countNumber, forKey: "totalItems")
                                                        
                                                    } else {
                                                        
                                                        if error != nil {
                                                            
                                                            print (error!)
                                                            
                                                        } else {
                                                            
                                                            print ("Error")
                                                        }
                                                        
                                                    }
                                                }
                                                
                                            }else{
                                                
                                                
                                                print("error")
                                                
                                            }
                                            
                                        }
                                        
                                        
                                    })
                                    
                                    
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                    _ = self.navigationController?.popViewController(animated: true)
                                    
                                    
                                }))
                                
                                
                                alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { (action) in
                                    
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                    _ = self.navigationController?.popViewController(animated: true)
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                    }else{
                        
                        print("Entered")
                        
                        // User has no active orders
                        
                        let order = PFObject(className: "Order")
                        
                        //Set the place
                        order["placeId"] = self.food?["placeId"]
                        //Set the user
                        order["userId"] = PFUser.current()!.objectId
                        //Set the state
                        order["state"] = 0
                        
                        let acl = PFACL()
                        acl.getPublicWriteAccess = true
                        acl.getPublicReadAccess = true
                        acl.setWriteAccess(true, for: PFUser.current()!)
                        order.acl = acl
                        
                        //Display
                        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                        self.activityIndicator.center = self.view.center
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                        self.view.addSubview(self.activityIndicator)
                        self.activityIndicator.startAnimating()
                        //Comment if you do not want to ignore interaction whilst
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        
                        order.saveInBackground { (success, error) -> Void in
                            
                            // added test for success 11th July 2016
                            
                            if success {
                                
                                UserDefaults.standard.set(order.objectId! as String, forKey: "activeOrder")
                                
                                print("Order has been saved.")
                                
                                let orderItem = PFObject(className: "OrderItem")
                                
                                //Set quantity
                                orderItem["quantity"] = self.countNumber
                                //Set total price
                                orderItem["price"] = self.totalpay
                                //Set the options selected
                                let foodOptions = self.food?["options"] as! Dictionary<String, Array<String>>
                                let keys = Array(foodOptions.keys)
                                var dictionary = [String: String]()
                                var i = 0
                                for key in keys {
                                    dictionary[key] = self.radioButtonControllers[i].selectedButton()?.title(for: [])! as String!
                                    i += 1
                                }
                                print(dictionary)
                                orderItem["options"] = dictionary
                                //Set the order
                                orderItem["orderId"] = order.objectId
                                //Set the food
                                orderItem["foodId"] = self.food?.objectId
                                
                                let acl = PFACL()
                                acl.getPublicWriteAccess = true
                                acl.getPublicReadAccess = true
                                acl.setWriteAccess(true, for: PFUser.current()!)
                                orderItem.acl = acl
                                
                                orderItem.saveInBackground { (success, error) -> Void in
                                    
                                    //Remove it
                                    self.activityIndicator.stopAnimating()
                                    //Comment if you commented the ignoring of interaction
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    
                                    // added test for success 11th July 2016
                                    
                                    if success {
                                        
                                        print("OrderItem has been saved.")
                                        UserDefaults.standard.set(self.countNumber, forKey: "totalItems")
                                        
                                        let oldPrice: Float = 0
                                        
                                        let newPrice = oldPrice + self.totalpay
                                        
                                        let query = PFQuery(className: "Order")
                                        
                                        query.getObjectInBackground(withId: order.objectId as String!, block: { (object, error) in
                                            
                                            if let orderObject = object {
                                                
                                                orderObject["price"] = newPrice
                                                
                                                orderObject.saveInBackground(block: { (success, error) in
                                                    
                                                    if error != nil {
                                                        
                                                        print(error!)
                                                        
                                                    }else{
                                                        
                                                        
                                                        if success {
                                                            
                                                            print("Order update price")
                                                            
                                                        }else{
                                                            
                                                            print("error")
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                })
                                                
                                            }
                                            
                                        })
                                        
                                        order["price"] = newPrice
                                        
                                    } else {
                                        
                                        if error != nil {
                                            
                                            print (error!)
                                            
                                        } else {
                                            
                                            print ("Error")
                                        }
                                        
                                    }
                                    
                                }
                                
                                print(order)
                                print(orderItem)
                                
                            } else {
                                
                                if error != nil {
                                    
                                    print (error!)
                                    
                                } else {
                                    
                                    print ("Error")
                                }
                                
                            }
                            
                        }
                        
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    //MARK: - Options Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return foodOptions.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderOptionsTableViewCell
        headerCell.backgroundColor = UIColor.white
        
        headerCell.nameLabel.text = Array(foodOptions.keys)[section]
        
        return headerCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let key = Array(foodOptions.keys)[section]
        
        let rows = foodOptions[key]?.count
        
        return rows!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OptionsTableViewCell
        
        let key = Array(foodOptions.keys)[indexPath.section]
        
        let name = foodOptions[key]?[indexPath.row]
        
        cell.radioButton.setTitle(name, for: [])
        
        //radioButtonControllers[indexPath.section].addButton(cell.radioButton!)
        buttonsArray.append(cell.radioButton!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
    
    func fillButtonsArray(){
        
        let keys = Array(foodOptions.keys)
        var e = 0
        var buttonsArrayA = [UIButton]()
        for key in keys {
            
            let size = foodOptions[key]?.count
            
            for _ in 0 ..< size!  {
                
                buttonsArrayA.append(buttonsArray.removeFirst())
                
            }
            e += 1
            
            let rButtonC = SSRadioButtonsController(buttons: buttonsArrayA)
            
            radioButtonControllers.append(rButtonC)
            
            buttonsArrayA.removeAll()
            
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
