//
//  MapPin.swift
//  ReportedPD
//
//  Created by dev on 2/19/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit

class MapPin: UIImageView {
    
    var numberLabel: UILabel!
    
    class func create(number: Int) -> MapPin {
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = String(number)
        label.textAlignment = NSTextAlignment.center
        
        let mapPin = MapPin()
        mapPin.addSubview(label)
        mapPin.numberLabel = label
        mapPin.unselectPin()
        return mapPin
    }
    
    func unselectPin() {
        image = UIImage(named: "map-unset-pin")
        frame = CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!)
        numberLabel.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height*0.6)
        numberLabel.font = UIFont.boldSystemFont(ofSize: 12)
    }
    
    func selectPin() {
        image = UIImage(named: "map-set-pin")
        frame = CGRect(x: 0, y: 0, width: (image?.size.width)!*2, height: (image?.size.height)!*2)
        numberLabel.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height*0.6)
        numberLabel.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
}
