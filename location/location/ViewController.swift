//
//  ViewController.swift
//  location
//
//  Created by binsonchang on 2016/10/28.
//  Copyright © 2016年 binsonchang. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currLocation:CLLocation!
    var lat:Double? = 0
    var lon:Double? = 0
    
    var myTimer:Timer?
    
    
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    @IBOutlet weak var timeResultLabel: UILabel!
    
    var Mytimer = Timer()
    var count = 120
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
//        var n = 10
//        print("before:\(n)")
//        self.newNumber(number: &n)
//        print("after:\(n)")
        self.timeResultLabel.text = String(format: "%02d:%02d",2,0)//"\(2):\(00)"
        self.zoneLabel.text = nil
        self.temperatureLabel.text = nil
        
        
    }
    
    func sayHello(name: String) {
        print("hello hello hello hello \(name)")
    }
    
    func hello(name:String, age:Int)  {
        print("\(name) is \(age) years old")
    }
    
    func hello2(name n:String, age a:Int)  {
        print("\(n) is \(a) years old")
    }
    
    func arithmeticTotal(numbers: Double...) -> Double {
        var total:Double = 0
        for number in numbers {
            total += number
        }
        return total;
    }
    
    func newNumber(number:inout Int) {
        number *= 2;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied {
//            showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
            print("Location services were previously denied. Please enable location services for this app in Settings.");
        }
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count - 1]
        currLocation = locations.last!
        
        if currLocation != nil {
            lat! = location.coordinate.latitude
            lon! = location.coordinate.longitude
            
            latLabel.text = String(format: "%.4f", lat!)
            lonLabel.text = String(format: "%.4f", lon!);
            
            locationManager.stopUpdatingLocation()
            
//            self.upDateLocation()
        }
    }
    
    func upDateLocation() {
        if let url = NSURL(string: "https://api.forecast.io/forecast/d3250bf407f0579c8355cd39cdd4f9e1/\(lat!),\(lon!)") {
            if let data = NSData(contentsOf: url as URL){
                do {
                    let parsed = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    let dataDic = parsed as? NSDictionary
                    
                    
                    self.zoneLabel.text = "\(dataDic!["timezone"]!)"//String(format: "%@",dataDic!["timezone"] as! String)
                    
                    let currentlyDic = dataDic!["currently"] as? NSDictionary
    
                    self.temperatureLabel.text = "\(currentlyDic!["temperature"]!)"
                    
                    print("\(currentlyDic!["temperature"])");
                }
                catch let error as NSError {
                    print("A JSON parsithng error occurred, here are the details:\n \(error)")
                }
            }
        }
        
    }
    
    
    @IBAction func clickTimerBtn(_ sender: AnyObject) {
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.upDateTime), userInfo: nil, repeats: true)
    }
    
    func upDateTime() {
//        count += 1
//        self.timeResultLabel.text = "\(count)"
        count -= 1
        
        let min = count/60
        let sec = count%60
        print("\(min):\(sec)")
        
        self.timeResultLabel.text = String(format: "%02d:%02d",min,sec)//"\(min):\(sec)"
        
        if count == 0 {
            myTimer?.invalidate()
            self.timeResultLabel.text = "倒數結束"
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

