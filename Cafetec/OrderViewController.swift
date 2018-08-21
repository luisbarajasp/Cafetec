//
//  OrderViewController.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 14/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit
import Parse

class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var orderDate: UILabel!
    @IBOutlet var orderPrice: UILabel!
    @IBOutlet var stateStatus: UILabel!
    @IBOutlet var statusColor: UILabel!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var dynamicView: UIView!
    @IBOutlet var backBtn: UIButton!
    
    var showBack = true
    
    var orderSelected: PFObject?
    
    var items = [PFObject]()

    @IBAction func backPressed(_ sender: Any) {
        if showBack {
            
            _ = self.navigationController?.popViewController(animated: true)
            
        }else{
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.tabBarController?.tabBar.isHidden = true
        
        if !showBack {
            
            backBtn.setImage(UIImage(named: "Times"), for: [])
            
        }else{
            
            backBtn.setImage(UIImage(named: "fa-angle-left-white"), for: [])
            
        }
        
        
        let query = PFQuery(className: "Place")
        
        let placeId = orderSelected?["placeId"] as! String
        
        print(placeId)
        
        query.whereKey("objectId", equalTo: placeId)
        
        do{
            
            let place = try query.getFirstObject()
            
            self.placeName.text = place["name"] as? String
            
            let twoDecimalPlaces = String(format: "%.2f", orderSelected?["price"] as! Float)
            
            self.orderPrice.text =  "Total: $\(twoDecimalPlaces)"
            
            (place["image"] as! PFFile).getDataInBackground { (data, error) in
                
                if let imageData = data {
                    
                    if let downloadedImage = UIImage(data: imageData) {
                        
                        self.placeImage.image = downloadedImage
                        
                    }
                    
                }
                
            }
            
            var dateOrder = ""
            
            let updatedAt = orderSelected?.updatedAt
            
            if updatedAt != nil {
                
                // change to a readable time format and change to local time zone
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/YY"
                dateFormatter.timeZone = NSTimeZone.local
                dateOrder = dateFormatter.string(from: updatedAt!)
                
            }
            
            self.orderDate.text = dateOrder
            
            let state = orderSelected?["state"] as! Int
            
            if state == 3 {
                
                self.statusColor.backgroundColor = UIColor(red: 0.9607843137, green: 0.3176470588, blue: 0.3725490196, alpha: 1)
                self.stateStatus.textColor = UIColor(red: 0.9607843137, green: 0.3176470588, blue: 0.3725490196, alpha: 1)
                
                self.stateStatus.text = "Cancelada"
                
            }else if state == 2{
                
                self.statusColor.backgroundColor = UIColor(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
                self.stateStatus.textColor = UIColor(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
                
                var timeStamp = ""
                
                let deliveredAt = orderSelected?["deliveredAt"]
                
                if deliveredAt != nil {
                    
                    // change to a readable time format and change to local time zone
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    dateFormatter.timeZone = NSTimeZone.local
                    timeStamp = dateFormatter.string(from: deliveredAt! as! Date)
                    
                }
                
                self.stateStatus.text = "Entregada " + timeStamp
                
            }else{
                
                self.statusColor.backgroundColor = UIColor(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)
                self.stateStatus.textColor = UIColor(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)
                self.stateStatus.text = "Por entregar"
                
            }
            
            
            
        }catch{
            
            print("Failed to get the place")
            
        }
        
    }
    
    func refresh() {
        
        self.items.removeAll()
            
            let query = PFQuery(className: "OrderItem")
            
            query.whereKey("orderId", equalTo: orderSelected?.objectId as String!)
        
            query.order(byDescending: "createdAt")
            
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
                
                //Resize tableview to the content height
                let point = self.tableView.frame.origin
                let width = self.tableView.frame.width
                var height = self.tableView.contentSize.height
                
                if height > 364 {
                    
                    height = 364
                    
                }
                
                let size = CGSize(width: width, height: height)
                let frame = CGRect(origin: point, size: size)
                
                
                
                self.tableView.frame = frame
                
            })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()

        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellPay", for: indexPath) as! CartPayTableViewCell
            
                
            cell.cardLabel.text = "···· " + (orderSelected?["card"] as! String!)
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            
            return cell
            
        }else{
            
            // MARK: - QR generation
            
            var qrcodeImage: CIImage!
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellQR", for: indexPath) as! OrderQRTableViewCell
            
            let orderId = orderSelected?.objectId as String!
            
            let data = orderId?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter?.outputImage
            
            let scaleX = cell.qrImage.frame.size.width / qrcodeImage.extent.size.width
            let scaleY = cell.qrImage.frame.size.height / qrcodeImage.extent.size.height
            
            let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            cell.qrImage.image = UIImage(ciImage: transformedImage)
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 {
            
            return 175
            
        }
        
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
