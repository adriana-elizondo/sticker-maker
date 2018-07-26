//
//  ViewController.swift
//  StickerMaker
//
//  Created by Adriana Elizondo on 2018/7/23.
//  Copyright © 2018 Adriana Elizondo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices

class ViewController: UIViewController {
    @IBOutlet weak var messagesLabel: UILabel!
    @IBOutlet weak var delayBetweenFrames: UILabel!
    @IBOutlet weak var slider: UISlider!
    private var url: URL?
    private var data: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messagesLabel.text = "Only the first 5 seconds will be used so choose wisely my young padawan..."
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "", message: "How do you want to do this?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Record it now", style: .default, handler: { (action) in
            self.presentPicker(with: .camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "From my videos", style: .default, handler: { (action) in
            self.presentPicker(with: .photoLibrary)
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentPicker(with type: UIImagePickerControllerSourceType){
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.videoMaximumDuration = 4
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultVC = segue.destination as? ResultViewController{
            resultVC.url = url
            resultVC.data = data
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerControllerMediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else { return }
        
        self.url = url
        //editing in progress
//        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
//        let player = AVPlayer(url: self.url!)
//
//        // Create a new AVPlayerViewController and pass it a reference to the player.
//        let controller = AVPlayerViewController()
//        controller.player = player
//
//        // Modally present the player and call the player's play() method when complete.
//        present(controller, animated: true) {
//            player.play()
//            let overlay = CropOverlayViewController(with: controller.videoBounds)
//            overlay.modalPresentationStyle = .overFullScreen
//            controller.present(overlay, animated: true, completion: nil)
//        }
        
            self.messagesLabel.text = "Making it a gif..."
            MediaHelper.createGifFromVideo(with: url) { (resultingUrl, data) in
                self.url = resultingUrl
                self.data = data
                self.performSegue(withIdentifier: "goToResult", sender: self)
            }
       
    }
}



