//
//  ReportController.swift
//  ReportedPD
//
//  Created by dev on 12/30/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Parse
import Photos
import GoogleMaps
import GooglePlaces

class ReportController: BaseViewController {
    
    @IBOutlet weak var tagListLabel: UILabel!
    @IBOutlet weak var tagListContainer: UIView!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var descView: BorderTextView!
    @IBOutlet weak var cityField: BorderTextView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var timeField: DateTextField!
    @IBOutlet weak var userTypeSeg: UISegmentedControl!
    @IBOutlet weak var advocateSubViewHideConstraint: NSLayoutConstraint!
    @IBOutlet weak var personField: ButtonTextField!
    @IBOutlet weak var personRemoveButton: UIButton!
    @IBOutlet weak var relationshipField: UITextField!
    @IBOutlet weak var relationshipRemoveButton: UIButton!
    
    @IBOutlet weak var addPhotoButton: BlueButton!
    @IBOutlet weak var addPhotoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView0: PhotoView!
    @IBOutlet weak var photo0HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView1: PhotoView!
    @IBOutlet weak var photo1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView2: PhotoView!
    @IBOutlet weak var photo2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView3: PhotoView!
    @IBOutlet weak var photo3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView4: PhotoView!
    @IBOutlet weak var photo4HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var officerView0: OfficerView!
    @IBOutlet weak var officer0HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var officerView1: OfficerView!
    @IBOutlet weak var officer1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var officerView2: OfficerView!
    @IBOutlet weak var officer2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var officerView3: OfficerView!
    @IBOutlet weak var officer3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addOfficerButton: UIButton!
    @IBOutlet weak var addOfficerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var resolutionContainer: UIView!
    @IBOutlet weak var investigateContainer: UIView!
    @IBOutlet weak var resolutionView: BorderTextView!
    @IBOutlet weak var investigateSwitch: UISwitch!
    @IBOutlet weak var publicSwitch: UISwitch!
    
    var reportModel: ReportModel!
    
    var isCommendType = false
    
    var imagePicker: UIImagePickerController!
    var coordinate: CLLocationCoordinate2D!
    var address: String!
    
    var person: PersonModel!
    
    var officerList = [OfficerModel]()
    var officerViewList: [(OfficerView, NSLayoutConstraint)]!
    
    var mediaList = [MediaModel]()
    var photoViewList: [(PhotoView, NSLayoutConstraint)]!
    
    var userDefault = UserDefaults.standard
    
    var editTag: TagView!
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = isCommendType ? "Commend" : "Report"

        if reportModel != nil {
            navigationItem.rightBarButtonItem = nil
        }
        
        // init tag list
        
        tagListContainer.layer.cornerRadius = AppData.cornerRadius
        tagListContainer.layer.borderColor = AppData.borderColor.cgColor
        tagListContainer.layer.borderWidth = 0.5
        tagList.delegate = self
        tagList.textFont = UIFont.systemFont(ofSize: 16)
        
        // init officer list
        
        addOfficerButton.layer.cornerRadius = AppData.cornerRadius
        addOfficerButton.layer.borderColor = AppData.blueColor.cgColor
        addOfficerButton.layer.borderWidth = 1
        
        officerViewList = [
            (officerView0, officer0HeightConstraint),
            (officerView1, officer1HeightConstraint),
            (officerView2, officer2HeightConstraint),
            (officerView3, officer3HeightConstraint)
        ]
        
        for i in 0..<officerViewList.count {
            let (officerView, _) = officerViewList[i]
            officerView.userButton.addTarget(self, action: #selector(touchOfficer), for: .touchUpInside)
        }
        
        // init image list
        
        addPhotoButton.layer.cornerRadius = AppData.cornerRadius
        addPhotoButton.layer.borderColor = AppData.blueColor.cgColor
        addPhotoButton.layer.borderWidth = 1
        
        photoViewList = [
            (photoView0, photo0HeightConstraint),
            (photoView1, photo1HeightConstraint),
            (photoView2, photo2HeightConstraint),
            (photoView3, photo3HeightConstraint),
            (photoView4, photo4HeightConstraint)
        ]
        
        for i in 0..<photoViewList.count {
            let (photoView, _) = photoViewList[i]
            photoView.imgView.layer.cornerRadius = AppData.cornerRadius
            photoView.deleteButton.addTarget(self, action: #selector(removeMedia), for: .touchUpInside)
            photoView.titleField.addTarget(self, action: #selector(updateMediaTitle), for: .editingChanged)
        }
        
        if reportModel == nil {
            
            // init tag list
            
            if let allegations = userDefault.array(forKey: "allegations") as? [String] {
                
                let allData = isCommendType ? AppData.getCommendationData() : AppData.getAllegationData()
                var allData1: [String] = [String]()
                for (_, value) in allData {
                    for item in value {
                        allData1.append(item)
                    }
                }
                for item in allegations {
                    if allData1.contains(item) {
                        tagList.addTag(item)
                    }
                }
                
            }
            
            editTag = tagList.addTag("Add +")
            editTag.enableRemoveButton = false
            editTag.tag = 1000
            editTag.tagBackgroundColor = AppData.blueColor
            editTag.textColor = UIColor.white
            editTag.onTap = { tagView in
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "AllegationsController") as! AllegationsController
                controller.isCommendType = self.isCommendType
                controller.selections = self.getAllegations()
                controller.selectedCallback = { (allegations) in
                    self.tagList.removeAllTags()
                    self.tagList.addTags(allegations)
                    self.tagList.addTagView(self.editTag)
                    
                    self.userDefault.set(allegations, forKey: "allegations")
                    self.userDefault.synchronize()
                }
                self.present(controller, animated: true, completion: nil)
            }
            
            // init describe
            
            descView.delegate = self
            descView.text = userDefault.string(forKey: "describe")
            
            // init location field
            
            if userDefault.string(forKey: "address") != nil {
                coordinate = CLLocationCoordinate2D(latitude: userDefault.double(forKey: "latitude"),
                                                    longitude: userDefault.double(forKey: "longitude"))
                address = userDefault.string(forKey: "address")
                addressField.text = userDefault.string(forKey: "address1")
                cityField.text = address
            }
            
            // init time field
            
            timeField.datePicker.maximumDate = Date()
            timeField.changedDate = { (date) in
                self.timeField.text = AppHelper.getDateTimeString(date)
                
                self.userDefault.set(date, forKey: "time")
                self.userDefault.synchronize()
            }
            timeField.setDate(userDefault.object(forKey: "time") as? Date)
            
            // user type
            
            userTypeSeg.selectedSegmentIndex = userDefault.integer(forKey: "userType")
            changeSegAction(userTypeSeg)
            
            // init persion field
            
            personField.clickCallback = { () in
                self.view.endEditing(true)
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "PersonController") as! PersonController
                controller.isCommendType = self.isCommendType
                controller.person = self.person
                controller.updateCallback = { (person) in
                    self.person = person
                    self.person.saveLocalStorage()
                    self.personField.text = person.firstName + " " + person.lastName
                    self.personRemoveButton.isHidden = false
                }
                self.present(controller, animated: true, completion: nil)
            }
            
            let pModel = PersonModel()
            pModel.loadLocalStorage()
            if pModel.firstName != nil {
                person = pModel
                personField.text = person.firstName + " " + person.lastName
                personRemoveButton.isHidden = false
            }
            
            // init relationship field
            
            relationshipField.delegate = self
            relationshipField.text = userDefault.string(forKey: "relationship")
            if relationshipField.text != "" {
                relationshipRemoveButton.isHidden = false
            }
            TextFiledPickerView.create(textFiled: relationshipField, data: AppData.getRelationship())
            
            // init officer list
            
            let officerCount = userDefault.integer(forKey: "officers")
            for i in 0..<officerCount {
                let officerModel = OfficerModel()
                officerModel.loadLocalStorage(at: i)
                officerList.append(officerModel)
            }
            updateOfficerList()
            
            // init image list
            
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            imagePicker.videoQuality = .typeHigh
            
            let mediaCount = userDefault.integer(forKey: "media")
            for i in 0..<mediaCount {
                let mediaModel = MediaModel()
                mediaModel.loadLocalStorage(at: i)
                mediaList.append(mediaModel)
            }
            updateMediaList()
            
            // resolution and investigate
            
            if (!isCommendType) {
                resolutionView.delegate = self
                resolutionView.text = userDefault.string(forKey: "resolution")
                investigateSwitch.isOn = userDefault.bool(forKey: "investigate")
            }
            
            // public
            
            publicSwitch.isOn = userDefault.bool(forKey: "public")
            
        } else {
            
            isCommendType = reportModel.commendation
            
            // init tag list
            
            tagList.enableRemoveButton = false
            tagList.addTags(reportModel.allegations)
            
            // init describe
            
            descView.isUserInteractionEnabled = false
            descView.text = reportModel.describe
            
            // init location field
            
            addressField.isUserInteractionEnabled = false
            cityField.text = reportModel.address
            addressField.text = reportModel.address1
            coordinate = CLLocationCoordinate2D(latitude: reportModel.latitude,
                                                longitude: reportModel.longitude)
            
            // init time field
            
            timeField.isUserInteractionEnabled = false
            timeField.text = reportModel.getDateTimeString()
            
            // user type
            
            userTypeSeg.isUserInteractionEnabled = false
            
            if reportModel.user_type == userTypeSeg.titleForSegment(at: 0)! {
                userTypeSeg.selectedSegmentIndex = 0
                advocateSubViewHideConstraint.constant = 150
            } else {
                userTypeSeg.selectedSegmentIndex = reportModel.user_type == userTypeSeg.titleForSegment(at: 1) ? 1 : 2
                advocateSubViewHideConstraint.constant = 0
            }
            
            // init persion field
            
            if userTypeSeg.selectedSegmentIndex == 0 {
                
                personField.clickCallback = { () in
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "PersonController") as! PersonController
                    controller.person = self.person
                    self.present(controller, animated: true, completion: nil)
                }
                
                if reportModel.person != nil {
                    person = reportModel.person
                    personField.text = person.firstName + " " + person.lastName
                }
                
                // init relationship field
                
                relationshipField.isUserInteractionEnabled = false
                relationshipField.text = reportModel.relationship
                
            }
            
            // init officer list
            
            addOfficerHeightConstraint.constant = 0
            officerList = reportModel.officerList
            updateOfficerList()
            
            // init image list
            
            addPhotoHeightConstraint.constant = 0
            mediaList = reportModel.mediaList
            updateMediaList()
            
            // resolution and investigate
            
            if !reportModel.commendation {
                resolutionView.isUserInteractionEnabled = false
                resolutionView.text = reportModel.resolution
                investigateSwitch.isUserInteractionEnabled = false
                investigateSwitch.isOn = reportModel.isInvestigated
            }
            
            // public
            
            publicSwitch.isUserInteractionEnabled = false
            publicSwitch.isOn = reportModel.isPublic
            
        }
        
        if isCommendType {
            tagListLabel.text = "Commendations"
            userTypeSeg.setTitle("Participant", forSegmentAt: 1)
            resolutionContainer.removeFromSuperview()
            investigateContainer.removeFromSuperview()
        }
        
    }
    
    func clearData() {
        userDefault.removeObject(forKey: "allegations")
        userDefault.removeObject(forKey: "describe")
        userDefault.removeObject(forKey: "latitude")
        userDefault.removeObject(forKey: "longitude")
        userDefault.removeObject(forKey: "address")
        userDefault.removeObject(forKey: "address1")
        userDefault.removeObject(forKey: "time")
        userDefault.removeObject(forKey: "userType")
        if person != nil {
            person.removeLocalStorage()
        }
        userDefault.removeObject(forKey: "relationship")
        userDefault.removeObject(forKey: "officers")
        userDefault.removeObject(forKey: "media")
        userDefault.removeObject(forKey: "resolution")
        userDefault.removeObject(forKey: "investigate")
        userDefault.removeObject(forKey: "public")
        userDefault.synchronize()
    }
    
    // allegations
    
    func getAllegations() -> [String] {
        var allegations = [String]()
        for tagView in tagList.tagViews {
            if tagView.tag != 1000 {
                allegations.append(tagView.title(for: .normal)!)
            }
        }
        return allegations
    }
    
    // city
    
    @IBAction func cityClickAction(_ sender: Any) {
        if reportModel == nil {
            let resultsViewController = GMSAutocompleteResultsViewController()
            resultsViewController.delegate = self
            self.searchController = UISearchController(searchResultsController: resultsViewController)
            self.searchController.searchResultsUpdater = resultsViewController
            self.present(self.searchController!, animated: true, completion: nil)
        }
    }

    // user type
    
    @IBAction func changeSegAction(_ sender: Any) {
        if userTypeSeg.selectedSegmentIndex == 0 {
            advocateSubViewHideConstraint.constant = 150
        } else {
            advocateSubViewHideConstraint.constant = 0
        }
        
        userDefault.set(userTypeSeg.selectedSegmentIndex, forKey: "userType")
        userDefault.synchronize()
    }
    
    // person
    
    @IBAction func removePerson(_ sender: Any) {
        person.removeLocalStorage()
        personField.text = ""
        personRemoveButton.isHidden = true
    }
    
    @IBAction func removeRelationship(_ sender: Any) {
        relationshipField.text = ""
        userDefault.removeObject(forKey: "relationship")
        userDefault.synchronize()
        relationshipRemoveButton.isHidden = true
    }
    
    // officer
    
    @IBAction func addOfficerAction(_ sender: Any) {
        OfficerController.showModal(officer: nil, updateCallback: { (officer) in
            self.officerList.append(officer)
            self.updateOfficerList()
        })
    }
    
    func touchOfficer(_ sender: Any) {
        
        let index = (sender as! UIView).superview?.superview?.tag
        let officer = officerList[index!]
        
        if reportModel != nil {
            
            OfficerController.showModal(officer: officer, updateCallback: nil)
            
        } else {
        
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let editAction = UIAlertAction(title: "Edit", style: .default) { (_) in
                OfficerController.showModal(officer: officer, updateCallback: { (officer) in
                    self.updateOfficerList()
                })
            }
            actionSheet.addAction(editAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (_) in
                self.officerList.remove(at: index!)
                self.updateOfficerList()
            }
            deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
            actionSheet.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true, completion: nil)
            
        }
    }
    
    func updateOfficerList() {
        
        for i in 0..<officerViewList.count {
            let (officerView, constraint) = officerViewList[i]
            if i < officerList.count {
                let officer = officerList[i]
                let str = "Officer - " + (officer.firstName != "" ? officer.firstName : "noname")                
                officerView.userButton.setTitle(str, for: .normal)
                officerView.userButton.layer.cornerRadius = AppData.cornerRadius
                officerView.userButton.layer.borderWidth = 0.5
                
                constraint.constant = 48
                if reportModel == nil {
                    officer.saveLocalStorage(at: i)
                }
            } else {
                constraint.constant = 0
            }
        }

        if reportModel == nil {
            userDefault.set(officerList.count, forKey: "officers")
            userDefault.synchronize()
            
            addOfficerHeightConstraint.constant = officerList.count < officerViewList.count ? 40 : 0
        }
        
    }
    
    // photo or video
    
    @IBAction func addPhotoAction(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func removeMedia(_ sender: Any) {
        view.endEditing(true)
        
        let index = (sender as! UIView).superview?.superview?.tag
        mediaList.remove(at: index!)
        updateMediaList()
    }
    
    func updateMediaTitle(_ sender: Any) {
        let titleField = sender as! UITextField
        let index = titleField.superview?.superview?.tag
        mediaList[index!].title = titleField.text!
        
        let key = String(format: "%d", index!)
        userDefault.set(titleField.text, forKey: "media_title" + key)
        userDefault.synchronize()
    }
    
    func setPhotoImage(at: Int, image: UIImage) {
        let (photoView, constraint) = photoViewList[at]
        photoView.imgView.image = image
        let w = image.size.width
        constraint.constant = photoView.frame.size.width * (image.size.height + 65*w/295) / (325*w/295)
    }
    
    func updateMediaList() {
        
        for i in 0..<photoViewList.count {
            
            let (photoView, constraint) = photoViewList[i]
            
            if i < mediaList.count {
                
                let mediaModel = mediaList[i]
                
                photoView.model = mediaModel
                photoView.deleteButton.isHidden = reportModel != nil
                photoView.loadingIcon.isHidden = true
                photoView.playIcon.isHidden = !mediaModel.isVideo || mediaModel.assetPath == nil
                photoView.titleField.isUserInteractionEnabled = reportModel == nil
                photoView.titleField.text = mediaModel.title
                
                if mediaModel.image != nil {
                    
                    setPhotoImage(at: i, image: mediaModel.image)
                    
                } else if mediaModel.assetPath != nil {
                
                    let url = URL(string: mediaModel.assetPath)
                    let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
                    if let photo = fetchResult.firstObject {
                        PHImageManager.default().requestImage(for: photo, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { (image, info) in
                            DispatchQueue.main.async {
                                mediaModel.image = image
                                self.setPhotoImage(at: i, image: image!)
                            }
                        }
                    }
                
                } else if mediaModel.imageFile != nil {
                    
                    photoView.loadingIcon.isHidden = false
                    photoView.loadingIcon.startAnimating()
                    mediaModel.imageFile.getDataInBackground(block: { (data, error) in
                        photoView.loadingIcon.isHidden = true
                        photoView.loadingIcon.stopAnimating()
                        if (error == nil) {
                            mediaModel.image = UIImage(data: data!)
                            self.setPhotoImage(at: i, image: mediaModel.image)
                        }
                    })
                    
                } else if mediaModel.videoFile != nil {
                    
                    photoView.loadingIcon.isHidden = false
                    photoView.loadingIcon.startAnimating()
                    mediaModel.videoFile.getPathInBackground(block: { (path, error) in
                        photoView.loadingIcon.isHidden = true
                        photoView.loadingIcon.stopAnimating()
                        if (error == nil) {
                            let asset = AVAsset(url: URL(fileURLWithPath: path!))
                            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
                            assetImageGenerator.appliesPreferredTrackTransform = true
                            var time = asset.duration
                            time.value = min(time.value, 1)
                            do {
                                let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                                mediaModel.image = UIImage(cgImage: imageRef)
                                mediaModel.assetPath = path
                                self.setPhotoImage(at: i, image: mediaModel.image)
                            } catch {
                                print("error")
                            }
                            photoView.playIcon.isHidden = false
                        }
                    })
                }
                
                if reportModel == nil {
                    mediaModel.saveLocalStorage(at: i)
                }
                
            } else {
                photoView.model = nil
                constraint.constant = 0
            }
        }
        
        if reportModel == nil {
            userDefault.set(mediaList.count, forKey: "media")
            userDefault.synchronize()
            
            addPhotoHeightConstraint.constant = mediaList.count < photoViewList.count ? 40 : 0
        }
        
    }
    
    // investigate and public
    
    @IBAction func changedSwitch(_ sender: Any) {
        let sw = sender as! UISwitch
        if sw == publicSwitch {
            userDefault.set(publicSwitch.isOn, forKey: "public")
        } else {
            userDefault.set(investigateSwitch.isOn, forKey: "investigate")
        }
        userDefault.synchronize()
    }
    
    // submit
    
    @IBAction func submitAction(_ sender: Any) {
        
        let allegations = getAllegations()
        if allegations.count == 0 {
            let message = "Please select " + (isCommendType ? "commendations" : "allegations")
            AppHelper.showAlert(title: nil, message: message, cancel: nil, cancelCallback: nil, ok: "OK", okCallback: nil)
            return
        }
        
        let describe = descView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if describe == "" {
            AppHelper.showAlert(title: nil, message: "Describe field is required", cancel: nil, cancelCallback: nil, ok: "OK", okCallback: { (_) in
                self.descView.becomeFirstResponder()
            })
            return
        }
        
        if cityField.text == "" {
            AppHelper.showAlert(title: nil, message: "City field is required", cancel: nil, cancelCallback: nil, ok: "OK", okCallback: nil)
            return
        }
        
        if timeField.text == "" {
            AppHelper.showAlert(title: nil, message: "Time field is required", cancel: nil, cancelCallback: nil, ok: "OK", okCallback: nil)
            return
        }
        
        if userTypeSeg.selectedSegmentIndex == 0 {
            if person == nil {
                AppHelper.showAlert(title: nil, message: "Person field is required", cancel: nil, cancelCallback: nil, ok: "OK", okCallback: nil)
                return
            }
            
            if relationshipField.text == "" {
                AppHelper.showAlert(title: nil, message: "Relationship field is required", cancel: nil, cancelCallback: nil, ok: "OK", okCallback: nil)
                return
            }
        }
        
        let object = PFObject(className: "report")
        
        let user = PFUser.current()
        object["user"] = user
        object["userinfo"] = [
            "firstName": user?["firstName"],
            "lastName": user?["lastName"],
            "email": user?["email"],
            "phone": user?["phone"]
        ]
        
        object["commendation"] = isCommendType
        object["allegations"] = allegations
        object["describe"] = describe
        object["position"] = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        object["address"] = address
        object["address1"] = addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        object["time"] = timeField.datePicker.date
        object["user_type"] = userTypeSeg.titleForSegment(at: userTypeSeg.selectedSegmentIndex)
        if userTypeSeg.selectedSegmentIndex == 0 {
            object["person"] = person.getInfo()
            object["relationship"] = relationshipField.text
        }
        
        if officerList.count > 0 {
            var officerData = [[String: Any]]()
            for officer in officerList {
                officerData.append(officer.getInfo())
            }
            object["officerData"] = officerData
        }

        if mediaList.count > 0 {
            var mediaData = [[String: Any]]()
            for mediaModel in mediaList {
                mediaData.append(mediaModel.getInfo())
            }
            object["mediaData"] = mediaData
        }
        
        if !isCommendType {
            object["resolution"] = resolutionView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            object["investigated"] = investigateSwitch.isOn
        }
        
        object["public"] = publicSwitch.isOn
        
        AppHelper.showLoading("Saving...")
        object.saveInBackground { (success, error) in
            AppHelper.hideLoading()
            if success {
                AppHelper.showAlert(title: "Thank you for sharing your story. Your voice is important and will be heard.",
                                    message: nil,
                                    cancel: "OK", cancelCallback: { (_) in
                                        self.clearData()
                                        HomeController.refreshRequest = true
                                        _ = self.navigationController?.popViewController(animated: true)
                },
                                    ok: nil, okCallback: nil)
            } else {
                AppHelper.handleError(error)
            }
        }
    
    }
    
    static func pushController(reportModel: ReportModel!, isCommendType: Bool) {
        
        let topCotroller = AppHelper.getTopController()!
        let controller = topCotroller.storyboard?.instantiateViewController(withIdentifier: "ReportController") as! ReportController
        controller.reportModel = reportModel
        controller.isCommendType = isCommendType
        topCotroller.navigationController?.pushViewController(controller, animated: true)
        
    }

}

extension ReportController: TagListViewDelegate {
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void {
        
        if tagView.tag != 1000 {
            
            sender.removeTagView(tagView)
            
            userDefault.set(getAllegations(), forKey: "allegations")
            userDefault.synchronize()
            
        }
        
    }
}

extension ReportController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaModel = MediaModel()
        mediaList.append(mediaModel)
        
        let refUrl = info[UIImagePickerControllerReferenceURL] as? URL
        mediaModel.assetPath = refUrl?.relativeString
        mediaModel.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if mediaModel.image == nil {
            mediaModel.isVideo = true
            
            let url = URL(string: mediaModel.assetPath)
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
            if let video = fetchResult.firstObject {
                PHImageManager.default().requestAVAsset(forVideo: video, options: nil, resultHandler: { (asset, _, info) in
                    do {
                        mediaModel.video = try Data(contentsOf: (asset as! AVURLAsset).url)
                    } catch {}
                })
            }
        }
        
        picker.dismiss(animated: true) {
            self.updateMediaList()
        }
        
    }
    
}

extension ReportController: UINavigationControllerDelegate {
    
}

extension ReportController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textFiled: UITextField) {
        if textFiled.text != "" && textFiled == relationshipField {
            relationshipRemoveButton.isHidden = false
            userDefault.set(relationshipField.text, forKey: "relationship")
        } else if textFiled == addressField {
            userDefault.set(addressField.text, forKey: "address1")
        }
        userDefault.synchronize()
    }
}

extension ReportController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descView {
            userDefault.set(descView.text, forKey: "describe")
        } else if !isCommendType && textView == resolutionView {
            userDefault.set(resolutionView.text, forKey: "resolution")
        }
        userDefault.synchronize()
    }
}

extension ReportController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        cityField.text = place.formattedAddress
        
        self.coordinate = place.coordinate
        self.address = place.formattedAddress
        self.cityField.text = self.address
        self.userDefault.set(coordinate.latitude, forKey: "latitude")
        self.userDefault.set(coordinate.longitude, forKey: "longitude")
        self.userDefault.set(self.address, forKey: "address")
        self.userDefault.synchronize()
        
        searchController.dismiss(animated: true, completion: nil)
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        dismiss(animated: true, completion: nil)
        print("Error: ", error.localizedDescription)
    }
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
