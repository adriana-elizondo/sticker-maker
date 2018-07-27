//
//  MediaHelper.swift
//  StickerMaker
//
//  Created by Adriana Elizondo on 2018/7/23.
//  Copyright © 2018 Adriana Elizondo. All rights reserved.
//

import Foundation
import Regift
import Photos
import AVFoundation

enum MediaHelperError : Error{
    case cancelled, unknown
}

class MediaHelper{
    static func createGifFromVideo(with url: URL, numberOfFrames: Int = 8, delayBetweenFrames: Float = 0.2, with completion: ((URL?, Data?) -> Void)?){
        let videoURL = url
        Regift.createGIFFromSource(videoURL, destinationFileURL: nil, frameCount: numberOfFrames, delayTime: delayBetweenFrames, loopCount: 0, size:  CGSize(width: 400, height: 400)) { (result) in
            if let data = NSData(contentsOfFile: result?.path ?? ""){
                if completion != nil{
                    completion!(result, data as Data)
                }
            }
        }
    }
    
    static func saveToLibrary(with data: Data, and url: URL, and completion:((Bool, Error?) -> Void)?){
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data as Data, options: nil)
            
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            creationRequest.addResource(with: .alternatePhoto, fileURL: url, options: options)
        }, completionHandler:completion)
    }
    
    static func resizeGif(){
        
    }
    
    static func squareCropVideo(inputURL: NSURL, completion: @escaping (_ outputURL : URL?, _ error: Error?) -> ())
    {
        let videoAsset: AVAsset = AVAsset( url: inputURL as URL )
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaType.video ).first! as AVAssetTrack
        
        let composition = AVMutableComposition()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize( width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height )
        videoComposition.frameDuration = CMTimeMake(1, 16)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        
        let transform1: CGAffineTransform = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: (clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
        let transform2 = transform1.rotated(by: .pi/2)
        let finalTransform = transform2
        
        
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        // Export
        let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "file.mov", isDirectory: true)
        do {
            try FileManager.default.removeItem(at: url)
        }catch{
            completion(nil, error)
            return
        }
        
        let croppedOutputFileUrl = url
        exportSession.outputURL = croppedOutputFileUrl
        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = AVFileType.mov
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed{
                    completion(croppedOutputFileUrl, nil)
                }else if exportSession.status == .failed{
                    completion(nil, exportSession.error)
                }else if exportSession.status == .cancelled{
                    completion(nil, MediaHelperError.cancelled)
                }else{
                    completion(nil, MediaHelperError.unknown)
                }
            }
        }

    }
}
