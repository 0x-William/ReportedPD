//
//  BaseViewController.swift
//  ReportedPD
//
//  Created by dev on 1/7/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var showKeyboard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown),
                                               name: Notification.Name.UIKeyboardDidShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        navigationController?.navigationBar.topItem?.title = ""
        
    }
    
    
    func keyboardWasShown(_ notification: NSNotification) {
        
        showKeyboard = true
        
        if scrollView != nil {
            let bottom_h = AppHelper.getRootController().view.frame.size.height - view.frame.origin.y - view.frame.size.height
            let info = notification.userInfo
            let size = (info?[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.height - bottom_h, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func keyboardWillBeHidden(_ notification: NSNotification) {
        showKeyboard = false
        
        if scrollView != nil {
            let contentInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension BaseViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return showKeyboard
    }
    
}
