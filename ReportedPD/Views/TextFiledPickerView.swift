//
//  TextFiledPickerView.swift
//  ReportedPD
//
//  Created by dev on 12/30/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit

class TextFiledPickerView: UIPickerView {

    var textField: UITextField!
    var data: [String]!
    
    static func create(textFiled: UITextField, data: [String]) -> TextFiledPickerView {
        
        let pickerView = TextFiledPickerView()
        pickerView.delegate = pickerView
        pickerView.dataSource = pickerView
        pickerView.textField = textFiled
        pickerView.data = data
        textFiled.inputView = pickerView        
        textFiled.settingDoneToolbar()
        
        for item in data {
            if textFiled.text == item {
                pickerView.selectRow(data.index(of: item)!, inComponent: 0, animated: true)
                break
            }
        }
        
        return pickerView
    }
}

extension TextFiledPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data?[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = data[row]
    }
    
}


extension TextFiledPickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
}



