//
//  OfficerModel.swift
//  ReportedPD
//
//  Created by dev on 1/12/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit
import Parse
import Photos

class OfficerModel: NSObject {

    var assetPath: String!
    var image: UIImage!
    var file: PFFile!
    
    var firstName: String!
    var lastName: String!
    var race: String!
    var sex: String!
    var physicalDesc: String!
    var desc: String!
    var precinct: String!
    var shield: String!
    var role: String!    
    var carWasMarked = false
    var patrolCar: String!
    var licensePlate: String!
    var officerWasUniformed = false
    
    override init() {
        super.init()
    }
    
    init(info: [String: Any]) {
        super.init()
        
        file = info["image"] as? PFFile
        firstName = info["firstName"] as? String
        lastName = info["lastName"] as? String
        race = info["race"] as? String
        sex = info["sex"] as? String
        physicalDesc = info["physicalDesc"] as? String
        desc = info["desc"] as? String
        precinct = info["precinct"] as? String
        shield = info["shield"] as? String
        role = info["role"] as? String
        carWasMarked = info["carWasMarked"] as! Bool
        patrolCar = info["patrolCar"] as? String
        licensePlate = info["licensePlate"] as? String
        officerWasUniformed = info["officerWasUniformed"] as! Bool
    }
    
    func getInfo() -> [String: Any] {
        var info: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "race": race,
            "sex": sex,
            "physicalDesc": physicalDesc,
            "desc": desc,
            "precinct": precinct,
            "shield": shield,
            "role": role,
            "carWasMarked": carWasMarked,
            "patrolCar": patrolCar,
            "licensePlate": licensePlate,
            "officerWasUniformed": officerWasUniformed
        ]
        
        if image != nil {
            info["image"] = PFFile(name: "photo.jpg", data: UIImageJPEGRepresentation(image, 0.7)!)!
        }
        
        return info
    }
    
    func loadLocalStorage(at: Int) {
        let userDefault = UserDefaults.standard
        let key = String(format: "%d", at)
        assetPath = userDefault.string(forKey: "officer_assetPath" + key)
        firstName = userDefault.string(forKey: "officer_firstName" + key)
        lastName = userDefault.string(forKey: "officer_lastName" + key)
        race = userDefault.string(forKey: "officer_race" + key)
        sex = userDefault.string(forKey: "officer_sex" + key)
        physicalDesc = userDefault.string(forKey: "officer_physicalDesc" + key)
        desc = userDefault.string(forKey: "officer_desc" + key)
        precinct = userDefault.string(forKey: "officer_precinct" + key)
        shield = userDefault.string(forKey: "officer_shield" + key)
        role = userDefault.string(forKey: "officer_role" + key)
        carWasMarked = userDefault.bool(forKey: "officer_carMarked" + key)
        patrolCar = userDefault.string(forKey: "officer_patrolCar" + key)
        licensePlate = userDefault.string(forKey: "officer_license" + key)
        officerWasUniformed = userDefault.bool(forKey: "officer_uniformed" + key)
        
        if assetPath != nil {
            let url = URL(string: assetPath)
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
            if let photo = fetchResult.firstObject {
                PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { (image, info) in
                    self.image = image
                }
            }
        }
    }
    
    func saveLocalStorage(at: Int) {
        let userDefault = UserDefaults.standard
        let key = String(format: "%d", at)
        userDefault.set(assetPath, forKey: "officer_assetPath" + key)
        userDefault.set(firstName, forKey: "officer_firstName" + key)
        userDefault.set(lastName, forKey: "officer_lastName" + key)
        userDefault.set(race, forKey: "officer_race" + key)
        userDefault.set(sex, forKey: "officer_sex" + key)
        userDefault.set(physicalDesc, forKey: "officer_physicalDesc" + key)
        userDefault.set(desc, forKey: "officer_desc" + key)
        userDefault.set(precinct, forKey: "officer_precinct" + key)
        userDefault.set(shield, forKey: "officer_shield" + key)
        userDefault.set(role, forKey: "officer_role" + key)
        userDefault.set(carWasMarked, forKey: "officer_carMarked" + key)
        userDefault.set(patrolCar, forKey: "officer_patrolCar" + key)
        userDefault.set(licensePlate, forKey: "officer_license" + key)
        userDefault.set(officerWasUniformed, forKey: "officer_uniformed" + key)
        userDefault.synchronize()
    }
    
}
