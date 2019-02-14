//
//  HelpController.swift
//  ReportedPD
//
//  Created by dev on 11/25/16.
//  Copyright © 2016 dev. All rights reserved.
//

import UIKit
import Parse

class HelpController: UITableViewController {

    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    
    var website: URL!
    var email: URL!
    var twitter: URL!
    var shareData: NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if website == nil {
            AppHelper.showLoading("loading...")
            let query :PFQuery = PFQuery(className: "Help")
            query.findObjectsInBackground(block: {(objects, error) in
                AppHelper.hideLoading()
                if error != nil {
                    NSLog("error" + (error?.localizedDescription)!)
                } else {
                    for object in objects! {
                        if let value = object["value"] as? String {
                            switch object["key"] as! String {
                            case "website":
                                self.website = URL(string: value)
                                let value1 = value.replacingOccurrences(of: "http://www.", with: "")
                                self.websiteLabel.text = "Go to " + value1
                            case "feedback-email":
                                self.email = URL(string: "mailto:" + value)
                            case "share-twitter":
                                self.shareData["shareTwitter"] = value
                            case "share-facebook":
                                self.shareData["shareFacebook"] = value
                            case "share-sms":
                                self.shareData["shareSMS"] = value
                            case "share-email-subject":
                                self.shareData["shareEmailSubject"] = value
                            case "share-email-body":
                                self.shareData["shareEmailBody"] = value
                            case "twitter-user":
                                self.twitter = URL(string: "twitter://user?screen_name=" + value)
                                self.followLabel.text = "Follow @" + value
                            default: break
                            }

                        }
                    }
                }
            })
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let url = website != nil ? website : URL(string: "http://www.reportedpd.com")!
            UIApplication.shared.openURL(url!)
        case 1:
            let url = email != nil ? email : URL(string: "mailto:reportedpd@gmail.com")!
            UIApplication.shared.openURL(url!)
        case 2:
            let itemProvider = MyCustomProvider(placeholderItem: shareData)
            let controller = UIActivityViewController(activityItems: [itemProvider], applicationActivities: nil)
            present(controller, animated: true, completion: nil)
        case 3:
            let url = twitter != nil ? twitter : URL(string: "twitter://user?screen_name=ReportedPD")!
            UIApplication.shared.openURL(url!)
        default: break
        }
        
    }
    
}

class MyCustomProvider: UIActivityItemProvider {
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        let shareData = placeholderItem as! NSDictionary
        if activityType == UIActivityType.postToTwitter {
            return shareData["shareTwitter"]
        }
        if activityType == UIActivityType.postToFacebook {
            UIPasteboard.general.string = shareData["shareFacebook"] as? String
            return ""
        }
        if activityType.rawValue == "com.apple.UIKit.activity.Message" {
            return shareData["shareSMS"]
        }
        if activityType.rawValue == "com.apple.UIKit.activity.Mail" {
            return shareData["shareEmailBody"]
        }
        
        return "http://www.reportedpd.com"
        
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType?.rawValue == "com.apple.UIKit.activity.Mail" {
            let shareData = placeholderItem as! NSDictionary
            return shareData["shareEmailSubject"] as! String
        }
        
        return ""
    }
    
}
