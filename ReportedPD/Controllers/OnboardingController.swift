//
//  OnboardingController.swift
//  ReportedPD
//
//  Created by dev on 12/29/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import Parse
import FirebaseAuthUI
import FirebasePhoneAuthUI

class OnboardingController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var readyButton: BlueButton!
    
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if PFUser.current() != nil {
            let identifier = ProfileController.isCompleted() ? "Main" : "ProfileNav"
            let controller = storyboard?.instantiateViewController(withIdentifier: identifier)
            UIApplication.shared.keyWindow?.rootViewController = controller
        }

        authUI = FUIAuth.defaultAuthUI()
        authUI.providers = [FUIPhoneAuth(authUI: authUI!)]
        authUI.delegate = self
        authUI.isSignInWithEmailHidden = true
        
        if Auth.auth().currentUser != nil {
            do {
                try authUI?.signOut()
            } catch let error {
                print ("Error signing out: %@", error)
            }
        }

    }
    
    func login(phoneNumber: String) {
        
        AppHelper.showLoading("", controller: UIApplication.shared.keyWindow?.rootViewController)
        
        let user = PFUser()
        user.username = phoneNumber
        user.password = "reportedpd"
        
        let offset = phoneNumber.substring(to: phoneNumber.index(phoneNumber.startIndex, offsetBy: 2)) == "+1" ? 2 : 1
        let subPhoneNumber = phoneNumber.substring(from: phoneNumber.index(phoneNumber.startIndex, offsetBy: offset))
        user.setValue(subPhoneNumber, forKey: "phone")
        
        user.signUpInBackground { (success, error) in
            
            if success {
                
                let identifier = ProfileController.isCompleted() ? "Main" : "ProfileNav"
                AppHelper.switchRootViewController(identifier: identifier)
                
            } else {
                
                if (error as! NSError).code == 202 {
                    
                    PFUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (_, error) in
                        if error == nil {
                            let identifier = ProfileController.isCompleted() ? "Main" : "ProfileNav"
                            AppHelper.switchRootViewController(identifier: identifier)
                        } else {
                            AppHelper.handleError(error)
                        }
                    })
                    
                } else {
                    AppHelper.handleError(error)
                }
            }
        }
        
    }
    
    @IBAction func readyAction(_ sender: Any) {
        
        if pageControl.currentPage < 4 {
            let x = (pageControl.currentPage+1) * Int(UIScreen.main.bounds.size.width)
            let currentPage = x / Int(UIScreen.main.bounds.size.width)
            if currentPage != pageControl.currentPage {
                scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            }
            return
        }
        
        AppHelper.showAlert(title: "", message: "ReportedPD will ask you for your phone number. This is so we can authenticate you in a safer way than with a password, as it requires you to physically have your phone with you. We will NOT use your phone number for anything else, nor will we share it with anyone.", cancel: nil, cancelCallback: nil, ok: "OK") { (_) in
            
//            self.login(phoneNumber: "+0123456789")
//            return
            
            let provider = self.authUI.providers.first as! FUIPhoneAuth
            provider.signIn(withPresenting: self)

        }
        
    }
    
}

extension OnboardingController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = pageControl.currentPage
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(UIScreen.main.bounds.size.width)
        if currentPage != pageControl.currentPage {
            readyButton.setTitle(pageControl.currentPage == 4 ? "I'm ready" : "Next", for: .normal)
        }
    }

}

extension OnboardingController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard let authError = error else {
            login(phoneNumber: (user?.phoneNumber)!)
            return
        }
        
        let errorCode = UInt((authError as NSError).code)
        
        switch errorCode {
        case FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in");
            break
        default:
            let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
            print("Login error: \((detailedError as! NSError).localizedDescription)");
        }
    }
    
}

