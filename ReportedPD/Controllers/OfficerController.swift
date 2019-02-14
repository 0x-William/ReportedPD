//
//  OfficerController.swift
//  ReportedPD
//
//  Created by dev on 1/12/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class OfficerController: BaseViewController {
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var heightPhotoConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstNameField: U_JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: U_JVFloatLabeledTextField!
    @IBOutlet weak var raceField: U_JVFloatLabeledTextField!
    @IBOutlet weak var clearRaceButton: UIButton!
    @IBOutlet weak var sexField: U_JVFloatLabeledTextField!
    @IBOutlet weak var clearSexButton: UIButton!
    @IBOutlet weak var physicalField: U_JVFloatLabeledTextView!
    @IBOutlet weak var descField: U_JVFloatLabeledTextView!
    @IBOutlet weak var roleSeg: UISegmentedControl!

    @IBOutlet weak var precinctField: U_JVFloatLabeledTextField!
    @IBOutlet weak var shieldField: U_JVFloatLabeledTextField!
    
    @IBOutlet weak var carSwitch: UISwitch!
    @IBOutlet weak var patrolCarField: U_JVFloatLabeledTextField!
    @IBOutlet weak var licenseField: U_JVFloatLabeledTextField!
    @IBOutlet weak var officerSwitch: UISwitch!
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var officer: OfficerModel!
    var updateCallback: ((OfficerModel) -> Void)!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        photoImageView.layer.cornerRadius = AppData.cornerRadius
        
        loadingIcon.isHidden = true
        
        physicalField.settingDoneToolbar()
        descField.settingDoneToolbar()
        
        raceField.delegate = self
        sexField.delegate = self
        
        if officer != nil {
            
            firstNameField.text = officer.firstName
            lastNameField.text = officer.lastName
            raceField.text = officer.race
            clearRaceButton.isHidden =  raceField.text == ""
            sexField.text = officer.sex
            clearSexButton.isHidden = sexField.text == ""
            physicalField.text = officer.physicalDesc
            descField.text = officer.desc
            roleSeg.selectedSegmentIndex = roleSeg.titleForSegment(at: 0) == officer.role ? 0 : 1
            precinctField.text = officer.precinct
            shieldField.text = officer.shield
            carSwitch.isOn = officer.carWasMarked
            patrolCarField.text = officer.patrolCar
            licenseField.text = officer.licensePlate
            officerSwitch.isOn = officer.officerWasUniformed
            
        } else {
            
            officer = OfficerModel()
            
            physicalField.text = ""
            descField.text = ""
            roleSeg.selectedSegmentIndex = 1
            
        }
        
        if updateCallback != nil {
            
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            if officer?.image != nil {
                setImage(officer.image)
            }
            
        } else {
            
            navBar.items?[0].rightBarButtonItem = nil            
            commentLabel.removeFromSuperview()
            firstNameField.isUserInteractionEnabled = false
            lastNameField.isUserInteractionEnabled = false
            raceField.isUserInteractionEnabled = false
            clearRaceButton.isHidden = true
            sexField.isUserInteractionEnabled = false
            clearSexButton.isHidden = true
            physicalField.isUserInteractionEnabled = false
            descField.isUserInteractionEnabled = false
            roleSeg.isUserInteractionEnabled = false
            precinctField.isUserInteractionEnabled = false
            shieldField.isUserInteractionEnabled = false
            carSwitch.isUserInteractionEnabled = false
            patrolCarField.isUserInteractionEnabled = false
            licenseField.isUserInteractionEnabled = false
            officerSwitch.isUserInteractionEnabled = false
            
            if officer.file != nil {
                
                photoButton.isHidden = true
                deleteButton.isHidden = true
                heightPhotoConstraint.constant = 200
                
                if officer.image == nil {
                    
                    loadingIcon.isHidden = false
                    loadingIcon.startAnimating()
                    
                    officer.file.getDataInBackground(block: { (data, error) in
                        if (error == nil) {
                    
                            self.loadingIcon.isHidden = true
                            self.loadingIcon.stopAnimating()
                    
                            self.officer.image = UIImage(data: data!)
                            self.photoImageView.image = self.officer.image
                        }
                    })
                    
                } else {
                    photoImageView.image = officer.image
                }
                
            } else {
                heightPhotoConstraint.constant = 0
            }
            
        }
        
        TextFiledPickerView.create(textFiled: raceField, data: AppData.getRaceData())
        TextFiledPickerView.create(textFiled: sexField, data: ["Male", "Female"])
        
    }
    
    func setImage(_ image: UIImage!) {
        officer.image = image
        photoImageView.image = image
        photoButton.isHidden = image != nil
        deleteButton.isHidden = image == nil
        heightPhotoConstraint.constant = image == nil ? 45 : 200
    }
    
    @IBAction func addPhotoAction(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func deletePhotoAction(_ sender: Any) {
        setImage(nil)
    }
    
    @IBAction func clearRace(_ sender: Any) {
        raceField.text = ""
        clearRaceButton.isHidden = true
    }
    
    @IBAction func clearSex(_ sender: Any) {
        sexField.text = ""
        clearSexButton.isHidden = true
    }
    
    @IBAction func updateAction(_ sender: Any) {
        
        officer.image = photoImageView.image
        officer.firstName = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        officer.lastName = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        officer.race = raceField.text
        officer.sex = sexField.text
        officer.physicalDesc = physicalField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        officer.desc = descField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        officer.role = roleSeg.titleForSegment(at: roleSeg.selectedSegmentIndex)
        officer.precinct = precinctField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        officer.shield = shieldField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        officer.carWasMarked = carSwitch.isOn
        officer.patrolCar = patrolCarField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        officer.licensePlate = licenseField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        officer.officerWasUniformed = officerSwitch.isOn
        
        dismiss(animated: true) {
            self.updateCallback?(self.officer)
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    static func showModal(officer: OfficerModel!, updateCallback: ((OfficerModel) -> Void)!) {
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OfficerController") as! OfficerController
        controller.officer = officer
        controller.updateCallback = updateCallback
        AppHelper.getTopController().present(controller, animated: true, completion: nil)
        
    }

}

extension OfficerController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let refUrl = info[UIImagePickerControllerReferenceURL] as! URL
        officer.assetPath = refUrl.relativeString
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        setImage(image!)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

extension OfficerController: UINavigationControllerDelegate {
    
}

extension OfficerController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textFiled: UITextField) {
        if textFiled.text != "" {
            if textFiled == raceField {
                clearRaceButton.isHidden = false
            } else if textFiled == sexField {
                clearSexButton.isHidden = false
            }
        }
    }
}
