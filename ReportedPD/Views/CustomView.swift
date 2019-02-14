//
//  CustomView.swift
//  ReportedPD
//
//  Created by dev on 12/29/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import UITextView_Placeholder

class RoundButton: UIButton {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = AppData.cornerRadius
        
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }

}

class BlueButton: RoundButton {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = AppData.blueColor
    }

}

class OrangeButton: RoundButton {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = AppData.orangeColor
    }
    
}

class BorderTextView: UITextView {
    
    var heiConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = AppData.cornerRadius
        layer.borderColor = AppData.borderColor.cgColor
        layer.borderWidth = 0.5
                
        backgroundColor = UIColor.clear
        settingDoneToolbar()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if text.isEmpty {
            if heiConstraint == nil && !placeholder.isEmpty {
                let h = placeholderLabel.frame.size.height + 16
                heiConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: h)
                self.addConstraints([heiConstraint])
            }
        } else {
            if heiConstraint != nil {
                self.removeConstraint(heiConstraint)
                heiConstraint = nil
            }
        }
        
    }
    
}


// =======================================================

class U_TextField: UITextField {
    
    @IBInspectable open var borderWidth: CGFloat = 0.5
    @IBInspectable open var borderColor: UIColor = AppData.borderColor
    
    private var border: CALayer!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        settingDoneToolbar()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if border == nil {
            border = addUnderline(width: borderWidth, color: borderColor)
        }
    }
    
    func clearError() {
        border?.borderColor = borderColor.cgColor
    }
    
    func showError() {
        border?.borderColor = UIColor.red.cgColor
    }
    
    func checkValid() -> Bool {
        if text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            showError()
            return false
        }
        clearError()
        return true
    }
    
}


// =======================================================

class U_MaskTextField: U_TextField {
    
    @IBInspectable open var maskText: String = ""
    
    private var digits = ""
    
    override open var text: String? {
        set {
            
            digits = ""
            
            var str = ""
            
            if newValue != nil {
                
                var newDigits = ""
                for chr in (newValue?.characters)! {
                    if chr >= "0" && chr <= "9" {
                        newDigits.append(chr)
                    }
                }
                
                for chr in maskText.characters {
                    if digits.characters.count == newDigits.characters.count {
                        break
                    }
                    if chr == "#" {
                        let digit = newDigits[newDigits.index(newDigits.startIndex, offsetBy: digits.characters.count)]
                        str.append(digit)
                        digits.append(digit)
                    } else {
                        str.append(chr)
                    }
                }
                
            }
            
            super.text = str
        }
        
        get {
            return digits
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    public func getDigits() -> String! {
        return digits
    }
    
    override func checkValid() -> Bool {
        var n = 0
        for chr in maskText.characters {
            if chr == "#" {
                n = n + 1
            }
        }
        
        if digits.characters.count != n {
            showError()
            return false
        }
        return true
    }
    
}

extension U_MaskTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if maskText == "" {
            return true
        }
        
        var newDigits = getDigits()!
        
        var pos = 0
        for i in 0..<range.location {
            if maskText[maskText.index(maskText.startIndex, offsetBy: i)] == "#" {
                pos = pos + 1
            }
        }
        
        if string == "" {
            var n = 0
            for i in range.location..<range.location+range.length {
                if maskText[maskText.index(maskText.startIndex, offsetBy: i)] == "#" {
                    n = n + 1
                }
            }
            let range = newDigits.index(newDigits.startIndex, offsetBy: pos)..<newDigits.index(newDigits.startIndex, offsetBy: pos+n)
            newDigits.removeSubrange(range)
        } else {
            var newString = ""
            for chr in string.characters {
                if chr >= "0" && chr <= "9" {
                    newString.append(chr)
                }
            }
            newDigits.insert(contentsOf: newString.characters, at: newDigits.index(newDigits.startIndex, offsetBy: pos))
        }
        
        text = newDigits
        
        return false
        
    }
}


// =======================================================

class U_JVFloatLabeledTextField: JVFloatLabeledTextField {
    
    @IBInspectable open var borderWidth: CGFloat = 0.5
    @IBInspectable open var borderColor: UIColor = AppData.borderColor
    
    private var border: CALayer!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        settingDoneToolbar()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if border == nil {
            border = addUnderline(width: borderWidth, color: borderColor)
        }
    }
    
    func clearError() {
        border?.borderColor = borderColor.cgColor
    }
    
    func showError() {
        border?.borderColor = UIColor.red.cgColor
    }
    
    func checkValid() -> Bool {
        if text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            showError()
            return false
        }
        clearError()
        return true
    }
    
}


// =======================================================

class U_JVFloatLabeledTextView: JVFloatLabeledTextView {
    
    @IBInspectable open var borderWidth: CGFloat = 0.5
    @IBInspectable open var borderColor: UIColor = AppData.borderColor
    
    private var border: CALayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if border != nil {
            border.removeFromSuperlayer()
        }
        border = addUnderline(width: borderWidth, color: borderColor)
    }
    
    func clearError() {
        border?.borderColor = borderColor.cgColor
    }
    
    func showError() {
        border?.borderColor = UIColor.red.cgColor
    }
    
    func checkValid() -> Bool {
        if text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            showError()
            return false
        }
        clearError()
        return true
    }

}


// ================================

class ButtonTextField: UITextField {
    
    var clickCallback: (() -> Void)!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
}

extension ButtonTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        clickCallback?()
        return false
    }
    
}

// ================================

class DateTextField: UITextField {
    
    var datePicker: UIDatePicker = UIDatePicker()
    
    var changedDate: ((Date) -> Void)!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        self.inputView = datePicker
        settingDoneToolbar()
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        setDate(sender.date)
    }
    
    func setDate(_ date: Date!) {
        if date != nil {
            datePicker.date = date
            changedDate?(date)
        }        
    }
}

// ================================

extension UIView {
    
    func addUnderline(width: CGFloat, color: UIColor) -> CALayer {
        let border = CALayer()
        border.borderColor = color.cgColor
        border.borderWidth = width
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        layer.addSublayer(border)
        return border
    }
}

extension UITextField {
    func settingDoneToolbar() {
        let doneToolbar: UIToolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        resignFirstResponder()
    }
}

extension UITextView {
    func settingDoneToolbar() {
        let doneToolbar: UIToolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        resignFirstResponder()
    }
}
