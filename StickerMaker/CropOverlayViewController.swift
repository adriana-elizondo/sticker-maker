//
//  CropOverlayViewController.swift
//  StickerMaker
//
//  Created by Adriana Elizondo on 2018/7/26.
//  Copyright © 2018 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

protocol CropOverlayDelegate : class {
    func didFinishCropping(with cropArea: CGRect)
}

class CropOverlayViewController: UIViewController{
    private var scrollVIew = UIScrollView()
    private var videoBounds : CGRect?
    private var cropRect : CGRect?
    private var newCropRect: CGRect?
    weak var delegate : CropOverlayDelegate?
    
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: Constants.statusBarHeight, width: UIScreen.main.bounds.width, height: Constants.navBarHeight))
        let navItem = UINavigationItem(title: "Scroll to crop");
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(dismissView))
        let cropItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(cropInRect))
        navItem.rightBarButtonItem = cropItem
        navItem.leftBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        return navBar
    }()
    
    init(with videoBounds: CGRect){
        super.init(nibName: nil, bundle: nil)
        
        self.videoBounds = videoBounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.frame = UIScreen.main.bounds
        var frameRect = view.frame
        frameRect.origin.y = (Constants.navBarHeight + Constants.statusBarHeight)
        
        scrollVIew.backgroundColor = UIColor.clear
        scrollVIew.frame = frameRect
        let biggerSize = CGRect(x: -(view.bounds.width * 0.25), y: (view.bounds.height * 0.25), width:(view.bounds.width * 1.5), height:(view.bounds.height * 1.5))
        scrollVIew.delegate = self
        scrollVIew.contentSize = biggerSize.size

        createOverlay()
        
        view.addSubview(navigationBar)
        view.addSubview(scrollVIew)
    }
    
    @objc private func dismissView(){
        dismiss(animated: true, completion: nil)
    }
    
    private func createOverlay(){
        let path = UIBezierPath(rect: CGRect(x: 0, y: (Constants.statusBarHeight + Constants.navBarHeight), width: scrollVIew.contentSize.width, height: scrollVIew.contentSize.height))
        var size : CGFloat = 200
        
        if (videoBounds?.size.width)! > (videoBounds?.size.height)! {
            size = (videoBounds?.size.width)!
        }else{
            size = (videoBounds?.size.height)!
        }
        
        let convertedCenter = view.convert(view.center, to: scrollVIew)

        let originX = convertedCenter.x - (size / 3.7)
        let originY = convertedCenter.y - (size / 3.7)
        cropRect = CGRect(x: (originX + (view.bounds.width * 0.25)), y: (originY + (view.bounds.height * 0.25)), width: size / 1.85, height: size / 1.85)
        let cropPath = UIBezierPath(rect: cropRect!)
        path.append(cropPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        
        scrollVIew.contentOffset = CGPoint(x: (view.bounds.width * 0.25), y: (view.bounds.height * 0.25))
        scrollVIew.layer.addSublayer(fillLayer)
    }
    
    @objc func cropInRect(){
        delegate?.didFinishCropping(with: newCropRect!)
    }
    
}

extension CropOverlayViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var calculatedRect = cropRect
        calculatedRect?.origin.x = ((cropRect?.origin.x)! - scrollView.contentOffset.x)
        calculatedRect?.origin.y = ((cropRect?.origin.y)! - scrollView.contentOffset.y)

        newCropRect = calculatedRect
    }
}
