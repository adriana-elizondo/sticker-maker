//
//  ResultViewController.swift
//  StickerMaker
//
//  Created by Adriana Elizondo on 2018/7/23.
//  Copyright © 2018 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

class ResultViewController: UIViewController{
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var saveIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messagesLabel: UILabel!{
        didSet{
            messagesLabel.text = ""
        }
    }
    
    @IBOutlet weak var wechatIndicator: UIActivityIndicatorView!
    
    //gif data received from previous controller
    var url: URL?
    var data: Data?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messagesLabel.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let data = try NSData(contentsOfFile: url?.path ?? "") as Data
            resultImage.image = UIImage.gif(data: data)
        } catch  {
            print(error)
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let data = data,
            let url = url else {return}
        saveIndicator.startAnimating()
        messagesLabel.text = "Saving..."
        MediaHelper.saveToLibrary(with: data, and: url) { (success, error) in
            DispatchQueue.main.async {
                self.saveIndicator.stopAnimating()
                
                if (success){
                    self.messagesLabel.text = ""
                    let alert = UIAlertController(title: "", message: "Ready!!! Check your camera roll", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    self.messagesLabel.text = "You fucked up somehow, try again maybe?"
                }
            }
        }
    }
    
    @IBAction func wechatTapped(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        activityController.completionWithItemsHandler = { (type, success, element, error) in
            
        }
        self.present(activityController, animated: true, completion: nil)
    }
}
