//
//  Preferences.swift
//  EggTimer
//
//  Created by macintosh on 2018/10/29.
//  Copyright © 2018 macintosh. All rights reserved.
//

import Foundation
struct Preferences {
    var selectedTime: TimeInterval {
        get {
            let saveTime = UserDefaults.standard.double(forKey: "selectedTime")
            if saveTime > 0 {
                return saveTime
            } else {
                return 360
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedTime")
        }
    }
}
