//
//  MediaModel.swift
//  ReportedPD
//
//  Created by dev on 1/31/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit
import Parse
import Photos
import AVFoundation
import AVKit

class MediaModel: NSObject {

    var assetPath: String!
    var image: UIImage!
    var video: Data!
    var title = ""
    
    var isVideo = false
    
    var imageFile: PFFile!
    var videoFile: PFFile!
    
    override init() {
        super.init()
    }
    
    init(info: [String: Any]) {
        super.init()
        
        imageFile = info["image"] as? PFFile
        videoFile = info["video"] as? PFFile
        isVideo = videoFile != nil
        title = info["title"] as! String        
    }
    
    func getInfo() -> [String: Any] {
        var info: [String: Any] = [
            "title": title
        ]
        if isVideo {
            info["video"] = PFFile(name: "video.mp4", data: video)
        } else {
            info["image"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 1.0)!)!
        }
        return info
    }
    
    func loadLocalStorage(at: Int) {
        let userDefault = UserDefaults.standard
        let key = String(format: "%d", at)
        assetPath = userDefault.string(forKey: "media_path" + key)
        isVideo = userDefault.bool(forKey: "media_video" + key)
        if isVideo {
            let url = URL(string: assetPath)
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url!], options: nil)
            if let video = fetchResult.firstObject {
                PHImageManager.default().requestAVAsset(forVideo: video, options: nil, resultHandler: { (asset, _, info) in
                    do {
                        self.video = try Data(contentsOf: (asset as! AVURLAsset).url)
                    } catch {}
                })
            }
        }
        if let str = userDefault.string(forKey: "media_title" + key) {
            title = str
        }
    }
    
    func saveLocalStorage(at: Int) {
        let userDefault = UserDefaults.standard
        let key = String(format: "%d", at)
        userDefault.set(assetPath, forKey: "media_path" + key)
        userDefault.set(isVideo, forKey: "media_video" + key)
        userDefault.synchronize()
    }
    
    func showMedia(imageRect: CGRect) {
        if isVideo && assetPath != nil {
            let controller = AppHelper.getTopController()
            let url = videoFile == nil ? URL(string: assetPath!) : URL(fileURLWithPath: assetPath!)
            let playerController = AVPlayerViewController()
            playerController.player = AVPlayer(url: url!)
            controller?.present(playerController, animated: true, completion: nil)
        } else if !isVideo && image != nil {
            AppHelper.showImageViewer(image: image!, imageRect: imageRect)
        }
    }
    
}
