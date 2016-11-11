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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lessCount(_ sender: Any) {
        if self.countNumber > 1 {
            self.countNumber -= 1
            
            count.setTitle("\(self.countNumber)", for: [])
            
            confirmOrderBtn.setTitle("Añadir \(self.countNumber) al carrito", for: [])
            
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
        
        radioButtonControllers[0].printButtonsArray()
        radioButtonControllers[1].printButtonsArray()
        
    }
    
    //MARK: - Options Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return foodOptions.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionTitle = ""
        
        let key = Array(foodOptions.keys)[section]
        
        sectionTitle = key
        
        return sectionTitle
        
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
                //buttonsArray.remove(at: i)
                print(buttonsArray.count)
                
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
