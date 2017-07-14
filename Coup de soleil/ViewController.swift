//
//  ViewController.swift
//  Coup de soleil
//
//  Created by Mohamed SADAT on 12/07/2017.
//  Copyright © 2017 Mohsadat. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import UserNotifications

class ViewController: UIViewController {
  
  
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var skinTypeLabel: UILabel!
  
  
  @IBOutlet weak var timeLabel: UILabel!
  
  
  
  // Initialize the default skinType and add an observable for any change
  var skinType = SkinType().type1 {
    didSet {
      skinTypeLabel.text = self.skinType
      Utilities().setSkinType(value: skinType)
      getUvData()
      getTemperatureData()
    }
  }
  
  var uvIndex = 8
  var tempNow = 5
  
  var burnTime: Double = 10
  
  // Initialize the location Manger
  let locationManager = CLLocationManager()
  
  var coords = CLLocationCoordinate2D(latitude: 40, longitude: 40)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    
    // get location when the app is opened
    getLocation()
    
    
    skinType = Utilities().getSkinType()
    skinTypeLabel.text = self.skinType
    
  }
  
  
  
  // Action when the user chooses to notify him
  @IBAction func notifyMeClicked(_ sender: Any) {
    
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .badge, .sound]) {
      (granted, error) in
      if granted {
        // Configuration of the notification's content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "C'est le moment 😎 !", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Vous commencez à brûler 🔥 ! Vous feriez mieux de vous mettre en dessous du parasol ⛱️, et de ne pas vous exposer au soleil 🌞 !", arguments: nil)
        content.sound = UNNotificationSound.default()
        // Defining how long to wait to send the notification according to burnTime
        self.calculateBurnTime()
        let timeToBurnSeconds = self.burnTime * 60
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeToBurnSeconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: "willburn", content: content, trigger: trigger)
        
        // Add the notification to notification center of the device !
        center.add(request)
      }
    }
    
  }
  
  // Action for the change skin button
  
  @IBAction func changeSkinClicked(_ sender: UIButton) {
    
    let alert = UIAlertController(title: "Type de peau", message: "Veuillez choisir votre type de peau !", preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: SkinType().type1, style: .default, handler: { (action) in
      self.skinType = SkinType().type1
    }))
    
    alert.addAction(UIAlertAction(title: SkinType().type2, style: .default, handler: { (action) in
      self.skinType = SkinType().type2
    }))
    
    alert.addAction(UIAlertAction(title: SkinType().type3, style: .default, handler: { (action) in
      self.skinType = SkinType().type3
    }))
    
    alert.addAction(UIAlertAction(title: SkinType().type4, style: .default, handler: { (action) in
      self.skinType = SkinType().type4
    }))
    
    alert.addAction(UIAlertAction(title: SkinType().type5, style: .default, handler: { (action) in
      self.skinType = SkinType().type5
    }))
    
    alert.addAction(UIAlertAction(title: SkinType().type6, style: .default, handler: { (action) in
      self.skinType = SkinType().type6
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  
  // Location Manager function to ask the user the authorisation about geolocation
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("Location location changed")
    
    if status == .authorizedWhenInUse {
      getLocation()
    }
    else if status == .denied
    {
      let errorTitle = "Error"
      let errorMessage = "Vous devez autoriser l'application à accéder à votre localisation dans les réglages"
      let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  
  
  
  
  func getLocation () {
    if let loc = locationManager.location?.coordinate {
      coords = loc
    }
  }
  
  
  
  
  func getUvData () {
    
    let url = WeatherUrl(lat: String(coords.latitude), long: String(coords.longitude)).getFullUrl()
    print("URL \(url)")
    Alamofire.request(url).responseJSON { response in
      print("alamo \(response.result)")
      
      if let JSON = response.result.value as? [String: Any] {
        
        if let data = JSON["data"] as? Dictionary<String, AnyObject> {
          
          if let weather = data["weather"] as? [Dictionary<String, AnyObject>] {
            if let uv = weather[0]["uvIndex"] as? String {
              if let uvI = Int(uv) {
                self.uvIndex = uvI
                print("UVINDEX = \(uvI)")
                self.updateUI(dataSuccess: true)
                return
              }
            }
          }
        }
      }
      
      self.updateUI(dataSuccess: false)
      
    }
    
  }
  
  
  
  
  
  
  func getTemperatureData () {
    let url = WeatherUrl(lat: String(coords.latitude), long: String(coords.longitude)).getFullUrl()
    Alamofire.request(url).responseJSON { response in
      
      if let JSON = response.result.value as? [String: Any] {
        
        if let data = JSON["data"] as? Dictionary<String, AnyObject> {
          
          if let current = data["current_condition"] as? [Dictionary<String, AnyObject>] {
            if let temp = current[0]["temp_C"] as? String {
              print("TEMPERATURE 1 = \(temp)")
              if let tempI = Int(temp) {
                self.tempNow = tempI
                print("TEMPERATURE = \(tempI)")
                self.updateUI(dataSuccess: true)
                return
              }
            }
          }
        }
      }
    }
  }
  
  
  
  
  
  
  
  
  
  
  func updateUI (dataSuccess: Bool) {
    DispatchQueue.main.async {
      // Case if loading failed
      
      if !dataSuccess {
        self.statusLabel.text = "Erreur ... nous réessayons ..."
        self.getUvData()
        self.getTemperatureData()
        return
      }
      
      // Case if loading successed
      self.activityIndicator.stopAnimating()
      self.statusLabel.text = "Indice UV : \(self.uvIndex), Température: \(self.tempNow)°C"
      self.calculateBurnTime()
      print("Vous allez brûler dans : \(self.burnTime)")
      
      self.timeLabel.text = String(format: "%.0f" ,self.burnTime)
    }
    
    
  }
  
  func calculateBurnTime () {
    var minutesToBurn: Double = 10
    
    switch skinType {
    case SkinType().type1:
      minutesToBurn = BurnTime().burnType1
    case SkinType().type2:
      minutesToBurn = BurnTime().burnType2
    case SkinType().type3:
      minutesToBurn = BurnTime().burnType3
    case SkinType().type4:
      minutesToBurn = BurnTime().burnType4
    case SkinType().type5:
      minutesToBurn = BurnTime().burnType5
    case SkinType().type6:
      minutesToBurn = BurnTime().burnType6
    default:
      minutesToBurn = BurnTime().burnType1
    }
    
    burnTime = minutesToBurn / Double(self.uvIndex)
    
  }
  
  
}


// MARK: - CLLocationManagerDelegate
extension UIViewController: CLLocationManagerDelegate {
  
}

