//
//  ReportModel.swift
//  ReportedPD
//
//  Created by dev on 12/31/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps

class ReportModel: NSObject {

    var commendation = false
    var allegations: [String]!
    var describe: String!
    var address: String!
    var address1: String!
    var latitude: Double!
    var longitude: Double!
    var time: Date!
    var user_type: String!
    var person: PersonModel!
    var relationship: String!
    var officerList = [OfficerModel]()
    var mediaList = [MediaModel]()
    var resolution: String!
    var isInvestigated = false
    var isPublic = false
    
    var cellHeight: CGFloat = 0
    var marker: GMSMarker?
    
    var userInfo: String!
    
    override init() {
        super.init()
    }
    
    init(pfObject: PFObject) {
        super.init()
        
        if let commendation = pfObject["commendation"] as? Bool {
            self.commendation = commendation
        }
        
        allegations = pfObject["allegations"] as! [String]
        describe = pfObject["describe"] as? String
        address = pfObject["address"] as? String
        address1 = pfObject["address1"] as? String
        let position = pfObject["position"] as? PFGeoPoint
        latitude = position?.latitude
        longitude = position?.longitude
        time = pfObject["time"] as? Date
        user_type = pfObject["user_type"] as? String
        
        if let personInfo = pfObject["person"] as? [String: Any] {
            person = PersonModel(info: personInfo)
        }
        
        relationship = pfObject["relationship"] as? String
        
        if let officerInfos = pfObject["officerData"] as? [[String: Any]] {
            for info in officerInfos {
                let officer = OfficerModel(info: info)
                officerList.append(officer)
            }
        }
        
        if let imageInfos = pfObject["mediaData"] as? [[String: Any]] {
            for info in imageInfos {
                let media = MediaModel(info: info)
                mediaList.append(media)
            }
        }
        
        resolution = pfObject["resolution"] as? String
        if let investigated = pfObject["investigated"] as? Bool {
            isInvestigated = investigated
        }
        isPublic = pfObject["public"] as! Bool
        
    }
    
    func getDateTimeString() -> String {        
        return AppHelper.getDateTimeString(time)
    }
    
    func getDays() -> String {
        
        let current = Date()
        let diffDays = Calendar.current.dateComponents([.day], from: time, to: current).day ?? 0
        var days = ""
        switch diffDays {
        case 0:
            days = "today"
        case 1:
            days = "yesterday"
        default:
            if (diffDays < 10) {
                days = "\(diffDays) days ago"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                let dateInfo = dateFormatter.string(from: time).components(separatedBy: " ")
                days = dateInfo[1] + " " + dateInfo[2] + " " + dateInfo[3]
            }
        }
        
        return days
    }
    
}
