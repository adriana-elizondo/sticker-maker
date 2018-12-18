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
    @IBOutlet weak var slider: UISlider!{
        didSet{
            slider.addTarget(self, action: #selector(updateLabel), for: .valueChanged)
        }
    }
    @IBOutlet weak var numberOfFrames: UITextField!
    private var url: URL?
    private var data: Data?
    private var controller = AVPlayerViewController()
    private var actionSheet : UIAlertController?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(dismissAllInputViews))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(tapGesture)
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
        actionSheet = UIAlertController(title: "", message: "How do you want to do this?", preferredStyle: .actionSheet)
        actionSheet?.addAction(UIAlertAction(title: "Record it now", style: .default, handler: { (action) in
            self.presentPicker(with: .camera)
        }))
        actionSheet?.addAction(UIAlertAction(title: "From my videos", style: .default, handler: { (action) in
            self.presentPicker(with: .photoLibrary)
        }))
        
        actionSheet?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        }))
        
        self.present(actionSheet!, animated: true, completion: nil)
    }
    
    private func presentPicker(with type: UIImagePickerControllerSourceType){
        let picker = LandscapeImagePicker()
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
    
    @objc private func updateLabel(){
        delayBetweenFrames.text = "\(slider.value) seconds"
    }
    
    @objc private func dismissAllInputViews(){
        guard numberOfFrames.isFirstResponder else {return}
        numberOfFrames.resignFirstResponder()
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
        let player = AVPlayer(url: self.url!)
        controller.player = player
        
        present(controller, animated: true) {
            player.play()
            let overlay = CropOverlayViewController(with: self.controller.videoBounds)
            overlay.modalPresentationStyle = .overFullScreen
            overlay.delegate = self
            self.controller.present(overlay, animated: true, completion: nil)
        }
    }
}

extension ViewController: CropOverlayDelegate{
    func didFinishCropping(with cropArea: CGRect) {
        dismiss(animated: true, completion: nil)
        var calculatedCrop = cropArea
        calculatedCrop.origin.y = controller.videoBounds.origin.y - cropArea.origin.y - (Constants.navBarHeight + Constants.statusBarHeight)
        
        print("I am going to crop in.... \(calculatedCrop)")

        self.messagesLabel.text = "Cropping your video..."
        MediaHelper.squareCropVideo(inputURL: (url! as NSURL), renderSize: controller.videoBounds.size, cropSize: calculatedCrop) { (url, error) in
            if error == nil{
                self.messagesLabel.text = "Making it a gif..."
                MediaHelper.createGifFromVideo(with: url!,numberOfFrames: Int(self.numberOfFrames.text ?? "10") ?? 10, delayBetweenFrames: self.slider.value) { (resultingUrl, data) in
                    self.url = resultingUrl
                    self.data = data
                    self.performSegue(withIdentifier: "goToResult", sender: self)
                }
            }else{
                self.messagesLabel.text = "Error ): \(error!)"
            }
        }
        
    }
}



