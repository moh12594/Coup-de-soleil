//
//  Constants.swift
//  Coup de soleil
//
//  Created by Mohamed SADAT on 14/07/2017.
//  Copyright © 2017 Mohsadat. All rights reserved.
//

import Foundation


struct WeatherUrl {
  private let baseUrl = "https://api.worldweatheronline.com/premium/v1/weather.ashx"
  private let key = "&key=7ad53e15c55b43d7a1d135006171407"
  private let numDaysForecast = "&num_of_days=1"
  private let format = "&format=json"
  private var coordStr = ""
  init (lat: String, long: String){
    self.coordStr = "?q=\(lat),\(long)"
  }
  
  func getFullUrl () -> String {
    return baseUrl + coordStr + key + numDaysForecast + format
  }
  
}

struct SkinType {
  let type1 = "Prototype I - Peau très blanche"
  let type2 = "Prototype II - Peau claire"
  let type3 = "Prototype III - Peau intermédiaire"
  let type4 = "Prototype IV - Peau mate"
  let type5 = "Prototype V - Peau brun foncé"
  let type6 = "Prototype VI - Peau très foncé"
  
}

struct BurnTime {
  // All times are in minutes !
  let burnType1: Double = 67
  let burnType2: Double = 100
  let burnType3: Double = 200
  let burnType4: Double = 300
  let burnType5: Double = 400
  let burnType6: Double = 500
}

struct defaultKeys {
  static let skinType = "skinType"
}
