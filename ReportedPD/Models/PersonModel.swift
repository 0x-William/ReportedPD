//
//  PersonModel.swift
//  ReportedPD
//
//  Created by dev on 1/12/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit

class PersonModel: NSObject {

    var firstName: String!
    var lastName: String!
    var phone: String!
    var email: String!
    var address: String!
    var city: String!
    var state: String!
    var zipcode: String!
    var dateOfBirth: String!
    
    var userType: String!
    
    override init() {
        super.init()
    }
    
    init(info: [String: Any]) {
        firstName = info["firstName"] as? String
        lastName = info["lastName"] as? String
        email = info["email"] as? String
        phone = info["phone"] as? String
        address = info["address"] as? String
        city = info["city"] as? String
        state = info["state"] as? String
        zipcode = info["zipcode"] as? String
        dateOfBirth = info["dateOfBirth"] as? String
        userType = info["user_type"] as? String
    }
    
    func getInfo() -> [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone": phone,
            "address": address,
            "city": city,
            "state": state,
            "zipcode": zipcode,
            "dateOfBirth": dateOfBirth,
            "user_type": userType
        ]
    }
    
    func loadLocalStorage() {
        let userDefault = UserDefaults.standard
        firstName = userDefault.string(forKey: "person_firstName")
        if firstName != nil {
            lastName = userDefault.string(forKey: "person_lastName")
            email = userDefault.string(forKey: "person_email")
            phone = userDefault.string(forKey: "person_phone")
            address = userDefault.string(forKey: "person_address")
            city = userDefault.string(forKey: "person_city")
            state = userDefault.string(forKey: "person_state")
            zipcode = userDefault.string(forKey: "person_zipcode")
            dateOfBirth = userDefault.string(forKey: "person_dateOfBirth")
            userType = userDefault.string(forKey: "person_userType")
        }
    }
    
    func saveLocalStorage() {
        let userDefault = UserDefaults.standard
        userDefault.set(firstName, forKey: "person_firstName")
        userDefault.set(lastName, forKey: "person_lastName")
        userDefault.set(phone, forKey: "person_phone")
        userDefault.set(email, forKey: "person_email")
        userDefault.set(address, forKey: "person_address")
        userDefault.set(city, forKey: "person_city")
        userDefault.set(state, forKey: "person_state")
        userDefault.set(zipcode, forKey: "person_zipcode")
        userDefault.set(dateOfBirth, forKey: "person_dateOfBirth")
        userDefault.set(userType, forKey: "person_userType")
        userDefault.synchronize()
    }
    
    func removeLocalStorage() {
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: "person_firstName")
        userDefault.removeObject(forKey: "person_lastName")
        userDefault.removeObject(forKey: "person_email")
        userDefault.removeObject(forKey: "person_phone")
        userDefault.removeObject(forKey: "person_address")
        userDefault.removeObject(forKey: "person_city")
        userDefault.removeObject(forKey: "person_state")
        userDefault.removeObject(forKey: "person_zipcode")
        userDefault.removeObject(forKey: "person_dateOfBirth")
        userDefault.removeObject(forKey: "person_userType")
        userDefault.synchronize()
    }
    
}
