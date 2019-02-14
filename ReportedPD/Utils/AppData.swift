//
//  AppData.swift
//  MyJobPitch
//
//  Created by dev on 12/21/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import Parse

class AppData: NSObject {

    static let blueColor = UIColor(red: 123/255.0, green: 114/255.0, blue: 233/255.0, alpha: 1)
    static let orangeColor = UIColor(red: 252/255.0, green: 136/255.0, blue: 15/255.0, alpha: 1)
    static let borderColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1)
        
    static let cornerRadius: CGFloat = 6
    
    
    static var data = [String: [String: [String]]]()
    
    static func getRaceData() -> [String] {
        return data["race"]!["_"]!
    }
    static func getGenderData() -> [String] {
        return data["gender"]!["_"]!
    }
    static func getRelationship() -> [String] {
        return data["relationship"]!["_"]!
    }
    static func getAllegationData() -> [String: [String]] {
        return data["allegations"]!
    }
    
    static func getCommendationData() -> [String: [String]] {
        return data["commendations"]!
    }
    
    static func getDefineData(completed: (()->Void)!) {
        
        AppHelper.showLoading("Loading...")
        
        let query = PFQuery(className: "Define")
        query.order(byAscending: "order")
        query.limit = 10000
        query.findObjectsInBackground { (objects, error) in
        
            AppHelper.hideLoading()
            
            if error == nil {
                
                for object in objects! {
                    
                    let type = (object.object(forKey: "type") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                    if type != nil && type != "" {
                        
                        if data[type!] == nil {
                            data[type!] = [String: [String]]()
                        }
                        
                        var category = (object.object(forKey: "category") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                        if category == nil || category == "" {
                            category = "_"
                        }
                        
                        if data[type!]?[category!] == nil {
                            data[type!]?[category!] = [String]()
                        }
                        
                        let name = (object.object(forKey: "name") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                        if name != nil && name != "" {
                            data[type!]?[category!]?.append(name!)
                        }
                    }
                    
                }
                
                completed?()
                                
            } else {
                
                AppHelper.showAlert(title: "What happened?",
                                    message: error?.localizedDescription,
                                    cancel: "OK", cancelCallback: nil,
                                    ok: nil, okCallback: nil)
                
            }
        }
    }
    
}
