//
//  AppHelper.swift
//  ReportedPD
//
//  Created by dev on 12/29/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import MBProgressHUD
import JTSImageViewController

class AppHelper: NSObject {

    static func getRootController() -> UIViewController! {

        var controller = UIApplication.shared.keyWindow?.rootViewController

        while controller?.presentedViewController != nil {
            controller = controller?.presentedViewController
        }

        return controller!

    }

    static func getTopController() -> UIViewController! {

        var controller = UIApplication.shared.keyWindow?.rootViewController

        while controller?.presentedViewController != nil {
            controller = controller?.presentedViewController
        }

        if controller is UITabBarController {
            controller = (controller as! UITabBarController).selectedViewController
        }

        if controller is UINavigationController {
            controller = (controller as! UINavigationController).topViewController
        }

        return controller!

    }

    static func switchRootViewController(identifier: String) {
        let currentRootController = UIApplication.shared.keyWindow?.rootViewController
        let newRootController = currentRootController?.storyboard?.instantiateViewController(withIdentifier: identifier)

        UIView.animate(withDuration: 0.3, animations: {
            currentRootController?.view.window?.alpha = 0
        }) { (finished) in
            currentRootController?.view.window?.rootViewController = newRootController
            UIView.animate(withDuration: 0.3, animations: {
                newRootController?.view.window?.alpha = 1
            })
        }

    }

    static func showLoading(_ message:String!) {
        showLoading(message, controller: getRootController())
    }
    
    static func showLoading(_ message:String!, controller: UIViewController!) {
        
        hideLoading()
        
        let hud = MBProgressHUD.showAdded(to: (controller.view)!, animated: true)
        hud.backgroundView.color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
        hud.bezelView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        hud.contentColor = UIColor.white
        hud.label.text = message
        
    }

    static func hideLoading() {
        let rootViewController = getRootController()!
        MBProgressHUD.hide(for: rootViewController.view, animated: true)
    }
    
    static func showAlert(title: String?, message: String?,
                          cancel: String?, cancelCallback: ((UIAlertAction) -> Swift.Void)?,
                          ok: String?, okCallback: ((UIAlertAction) -> Swift.Void)?) {
        
        hideLoading()
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        if cancel != nil {
            let action = UIAlertAction(title: cancel, style: .cancel, handler: cancelCallback)
            alertController.addAction(action)
        }
        if ok != nil {
            let action = UIAlertAction(title: ok, style: .default, handler: okCallback)
            alertController.addAction(action)
        }
        getTopController().present(alertController, animated: true, completion: nil)
    }
    
    static func handleError(_ error: Error!) {
        showAlert(title: "What happened?",
                  message: error?.localizedDescription,
                  cancel: "OK", cancelCallback: nil,
                  ok: nil, okCallback: nil)
    }
    
    static func getDateTimeString(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full
        var dayofweek = dateFormatter.string(from: date).components(separatedBy: ",")[0] as String
        dayofweek = dayofweek.substring(to: dayofweek.index(dayofweek.startIndex, offsetBy: 3))
        
        dateFormatter.dateStyle = .medium
        let dateInfo = dateFormatter.string(from: date).components(separatedBy: " ")
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dayofweek + " " + dateInfo[0] + " " + dateInfo[1] + " " + dateFormatter.string(from: date)
        
    }
    
    static func showImageViewer(image: UIImage, imageRect: CGRect) {
        let controller = getTopController()
        
        let imageInfo = JTSImageInfo()
        imageInfo.image = image
        imageInfo.referenceRect = imageRect
        imageInfo.referenceView = controller?.view
        
        let imageViewer = JTSImageViewController.init(imageInfo: imageInfo, mode: .image, backgroundStyle: .init(rawValue: 0))
        imageViewer?.show(from: controller, transition: .fromOriginalPosition)
    }

}
