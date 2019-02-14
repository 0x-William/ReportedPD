//
//  ProfileController.swift
//  ReportedPD
//
//  Created by dev on 12/29/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import Parse

class ProfileController: BaseViewController {

    @IBOutlet weak var firstNameField: U_JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: U_JVFloatLabeledTextField!
    @IBOutlet weak var emailField: U_TextField!
    @IBOutlet weak var phoneField: U_MaskTextField!
    @IBOutlet weak var addressField: U_JVFloatLabeledTextField!
    @IBOutlet weak var cityField: U_JVFloatLabeledTextField!
    @IBOutlet weak var stateField: U_JVFloatLabeledTextField!
    @IBOutlet weak var zipcodeField: U_JVFloatLabeledTextField!
    @IBOutlet weak var raceField: U_JVFloatLabeledTextField!
    @IBOutlet weak var clearRaceButton: UIButton!
    @IBOutlet weak var genderField: U_JVFloatLabeledTextField!
    @IBOutlet weak var clearGenderButton: UIButton!
    @IBOutlet weak var birthYearField: U_JVFloatLabeledTextField!
    @IBOutlet weak var clearBirthYearButton: UIButton!
    
    var completed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = "Profile"
        
        completed = ProfileController.isCompleted()
        
        if completed == true {
            load()
        } else {
            navigationItem.leftBarButtonItem = nil
            AppData.getDefineData(completed: {
                self.load()
            })
        }
        
        raceField.delegate = self
        genderField.delegate = self
        birthYearField.delegate = self
        
    }
    
    func load() {
        
        let user = PFUser.current()!
        firstNameField.text = user.object(forKey: "firstName") as! String?
        lastNameField.text = user.object(forKey: "lastName") as! String?
        emailField.text = user.object(forKey: "email") as! String?
        phoneField.text = user.object(forKey: "phone") as! String?
        addressField.text = user.object(forKey: "address") as! String?
        cityField.text = user.object(forKey: "city") as! String?
        stateField.text = user.object(forKey: "state") as! String?
        zipcodeField.text = user.object(forKey: "zipcode") as! String?
        raceField.text = user.object(forKey: "race") as! String?
        clearRaceButton.isHidden = raceField.text == ""
        genderField.text = user.object(forKey: "gender") as! String?
        clearGenderButton.isHidden = genderField.text == ""
        birthYearField.text = user.object(forKey: "birthYear") as! String?
        clearBirthYearButton.isHidden = birthYearField.text == ""
        
        _ = TextFiledPickerView.create(textFiled: raceField, data: AppData.getRaceData())
        _ = TextFiledPickerView.create(textFiled: genderField, data: AppData.getGenderData())
        
        var years = [String]()
        let components: DateComponents = Calendar.current.dateComponents([Calendar.Component.year], from: Date())
        for i in 1900..<NSInteger(components.year!) {
            years.append(String(i))
        }
        let yearPicker = TextFiledPickerView.create(textFiled: birthYearField, data: years)
        if birthYearField.text == "" {            
            yearPicker.selectRow(components.year!-1900, inComponent: 0, animated: false)
        }
    }
    
    func close() {
        AppHelper.hideLoading()
        dismiss(animated: true, completion: nil)        
    }

    @IBAction func clearRace(_ sender: Any) {
        raceField.text = ""
        clearRaceButton.isHidden = true
    }
    
    @IBAction func clearGender(_ sender: Any) {
        genderField.text = ""
        clearGenderButton.isHidden = true
    }
    
    @IBAction func clearBirthYear(_ sender: Any) {
        birthYearField.text = ""
        clearBirthYearButton.isHidden = true
    }

    @IBAction func updateAction(_ sender: AnyObject) {

        view.endEditing(true)
        
        let firstNameField_valid = firstNameField.checkValid()
        let lastNameField_valid = lastNameField.checkValid()
        let emailField_valid = emailField.checkValid()
        let phoneField_valid = phoneField.checkValid()
        if  !firstNameField_valid || !lastNameField_valid || !emailField_valid || !phoneField_valid {
            return
        }

        let firstName: String = (firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        let lastName: String = (lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        let email: String = (emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        let phone: String = phoneField.text!
        let address: String = (addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        let city: String = (cityField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        let state: String = (stateField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        let zipcode: String = (zipcodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        let race: String = raceField.text!
        let gender: String = genderField.text!
        let birthYear: String = birthYearField.text!
        
        let user = PFUser.current()!
        user.setObject(firstName, forKey: "firstName")
        user.setObject(lastName, forKey: "lastName")
        user.setObject(email, forKey: "email")
        user.setObject(phone, forKey: "phone")
        user.setObject(address, forKey: "address")
        user.setObject(city, forKey: "city")
        user.setObject(state, forKey: "state")
        user.setObject(zipcode, forKey: "zipcode")
        user.setObject(race, forKey: "race")
        user.setObject(gender, forKey: "gender")
        user.setObject(birthYear, forKey: "birthYear")
        
        AppHelper.showLoading("Updating...")
        
        user.saveInBackground(block: { (success, error) in
            if error == nil {
                if self.completed {
                    self.close()
                } else {
                    AppHelper.switchRootViewController(identifier: "Main")
                }
            } else {
                AppHelper.handleError(error)
            }
        })
        
    }

    @IBAction func logoutAction(_ sender: Any) {
        
        AppHelper.showAlert(title: nil, message: "Are you sure you want to log out?", cancel: "Cancel", cancelCallback: nil, ok: "Log Out") { (_) in
            AppHelper.showLoading("")
            
            PFUser.logOutInBackground { (error) in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    AppHelper.switchRootViewController(identifier: "OnboardingNav")
                } else {
                    AppHelper.handleError(error)
                }
            }
        }
        
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        close()
    }
    
    static func isCompleted() -> Bool {
        
        if let user = PFUser.current() {
            return  user.object(forKey: "firstName") as? String != nil
        }
        
        return false
        
    }

}

extension ProfileController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textFiled: UITextField) {
        if textFiled.text != "" {
            if textFiled == raceField {
                clearRaceButton.isHidden = false
            } else if textFiled == genderField {
                clearGenderButton.isHidden = false
            } else if textFiled == birthYearField {
                clearBirthYearButton.isHidden = false
            }
        }
    }
}
