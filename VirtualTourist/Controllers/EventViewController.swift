//
//  EventViewController.swift
//  VirtualTourist
//
//  Created by MAC on 09/02/2019.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit
import Kingfisher

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var networkObject = NetworkConnection()
    var lat = 0.0
    var lon = 0.0

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        networkObject.getEvent(lat: lat, lon: lon) { (success, message, error) in
            if (success == true && AllEventsArray.EventsArray.count != 0) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }else if (success == true && AllEventsArray.EventsArray.count == 0){
                 self.showAlert(message: "Events for this location is unavailable")
            }else {
                self.showAlert(message: "Please check your internet connection")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllEventsArray.EventsArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! TableViewCell
        let imageUrl = URL(string: AllEventsArray.EventsArray[indexPath.row].eventImageUrl)
        let resource = ImageResource(downloadURL: imageUrl!)
        cell.eventImage.kf.indicatorType = .activity
        cell.eventImage.kf.setImage(with: resource, placeholder: UIImage(named: "Placeholder"))
        
        cell.eventName.text = AllEventsArray.EventsArray[indexPath.row].eventName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return UIApplication.shared.open(NSURL(string: AllEventsArray.EventsArray[indexPath.row].eventWebPageUrl)! as URL)
    }
}
