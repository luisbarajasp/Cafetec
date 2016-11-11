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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "Test"
        
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
