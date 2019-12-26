//
//  Weather.swift
//  Weather2
//
//  Created by Никита on 26.12.2019.
//  Copyright © 2019 Nikita Glushchenko. All rights reserved.
//

import SwiftyJSON

class Weather {
    var cityName: String?
    var temp: Double?
    
    init(json: JSON) {
        self.cityName = json["name"].stringValue
        self.temp = json["main"]["temp"].doubleValue
    }
}

