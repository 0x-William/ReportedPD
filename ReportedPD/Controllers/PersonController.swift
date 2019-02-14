//
//  PersonController.swift
//  ReportedPD
//
//  Created by dev on 1/8/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit
import ContactsUI

class PersonController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNameField: U_JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: U_JVFloatLabeledTextField!
    @IBOutlet weak var emailField: U_TextField!
    @IBOutlet weak var phoneField: U_MaskTextField!
    @IBOutlet weak var addressField: U_JVFloatLabeledTextField!
    @IBOutlet weak var cityField: U_JVFloatLabeledTextField!
    @IBOutlet weak var stateField: U_JVFloatLabeledTextField!
    @IBOutlet weak var zipcodeField: U_JVFloatLabeledTextField!
    @IBOutlet weak var dateOfBirthField: U_JVFloatLabeledTextField!    
    @IBOutlet weak var clearDateOfBirthButton: UIButton!
    @IBOutlet weak var userTypeSeg: UISegmentedControl!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var topView: UIView!
    
    var person: PersonModel!
    var updateCallback: ((PersonModel) -> Void)!
    
    var yearPicker: TextFiledPickerView!
    
    var isCommendType = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if isCommendType {
            titleLabel.text = "Add participant or witness\n(All fields optional)"
            userTypeSeg.setTitle("Participant", forSegmentAt: 0)
        }
        
        if person != nil {
            firstNameField.text = person.firstName
            lastNameField.text = person.lastName
            emailField.text = person.email
            phoneField.text = person.phone
            addressField.text = person.address
            cityField.text = person.city
            stateField.text = person.state
            zipcodeField.text = person.zipcode
            dateOfBirthField.text = person.dateOfBirth
            clearDateOfBirthButton.isHidden = dateOfBirthField.text == ""
            if person.userType == userTypeSeg.titleForSegment(at: 1) {
                userTypeSeg.selectedSegmentIndex = 1
            }
        }
        
        if updateCallback != nil {
            var years = [String]()
            let components: DateComponents = Calendar.current.dateComponents([Calendar.Component.year], from: Date())
            for i in 1900..<NSInteger(components.year!) {
                years.append(String(i))
            }
            yearPicker = TextFiledPickerView.create(textFiled: dateOfBirthField, data: years)
            if dateOfBirthField.text == "" {
                yearPicker.selectRow(components.year!-1900, inComponent: 0, animated: false)
            }
            dateOfBirthField.delegate = self
        } else {
            navBar.items?[0].rightBarButtonItem = nil
            topView.removeFromSuperview()
            firstNameField.isUserInteractionEnabled = false
            lastNameField.isUserInteractionEnabled = false
            emailField.isUserInteractionEnabled = false
            phoneField.isUserInteractionEnabled = false
            addressField.isUserInteractionEnabled = false
            cityField.isUserInteractionEnabled = false
            stateField.isUserInteractionEnabled = false
            zipcodeField.isUserInteractionEnabled = false
            dateOfBirthField.isUserInteractionEnabled = false
            clearDateOfBirthButton.isHidden = true
            userTypeSeg.isUserInteractionEnabled = false
        }
    }

    @IBAction func contactsAction(_ sender: Any) {
    
        let controller = CNContactPickerViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func clearDateOfBirth(_ sender: Any) {
        dateOfBirthField.text = ""
        clearDateOfBirthButton.isHidden = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateAction(_ sender: Any) {
        
        view.endEditing(true)
        
        if  !firstNameField.checkValid() {
            return
        }
        
        let person = PersonModel()
        person.firstName = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        person.lastName = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        person.email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        person.phone = phoneField.text
        person.address = addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        person.city = cityField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        person.state = stateField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        person.zipcode = zipcodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        person.dateOfBirth = dateOfBirthField.text
        person.userType = userTypeSeg.titleForSegment(at: userTypeSeg.selectedSegmentIndex)
        
        dismiss(animated: true) { 
            self.updateCallback?(person)
        }
        
    }
    
}

extension PersonController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        firstNameField.text = contact.givenName
        lastNameField.text = contact.familyName
        
        if contact.phoneNumbers.count > 0 {
            phoneField.text = contact.phoneNumbers[0].value.stringValue
        } else {
            phoneField.text = ""
        }
        
        if contact.emailAddresses.count > 0 {
            emailField.text = contact.emailAddresses[0].value as String
        } else {
            emailField.text = ""
        }
        
        if contact.postalAddresses.count > 0 {
            let postalAddress = contact.postalAddresses[0].value
            addressField.text = postalAddress.street
            cityField.text = postalAddress.city
            stateField.text = postalAddress.state
            zipcodeField.text = postalAddress.postalCode
        } else {
            addressField.text = ""
            cityField.text = ""
            stateField.text = ""
            zipcodeField.text = ""
        }
        
        if let dateOfBirth = contact.birthday?.date {
            let components: DateComponents = Calendar.current.dateComponents([Calendar.Component.year], from: dateOfBirth)
            dateOfBirthField.text = NSNumber(value: components.year!).stringValue
            yearPicker.selectRow(components.year!-1900, inComponent: 0, animated: false)
            clearDateOfBirthButton.isHidden = false
        } else {
            //yearPicker.selectRow(-1, inComponent: 0, animated: false)
            //clearDateOfBirthButton.isHidden = true
        }
        
    }
    
}

extension PersonController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textFiled: UITextField) {
        if textFiled.text != "" && textFiled == dateOfBirthField {
            clearDateOfBirthButton.isHidden = false
        }
    }
}
