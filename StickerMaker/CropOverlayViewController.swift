//
//  CropOverlayViewController.swift
//  StickerMaker
//
//  Created by Adriana Elizondo on 2018/7/26.
//  Copyright © 2018 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

class CropOverlayViewController: UIViewController{
    private var scrollVIew = UIScrollView()
    private var videoBounds : CGRect?
    private var cropRect : CGRect?
    
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
        
        scrollVIew.backgroundColor = UIColor.clear
        scrollVIew.frame = view.frame
        let biggerSize = CGRect(x: 0, y: 0, width:(view.bounds.width * 1.7), height:(view.bounds.height * 1.2))
        scrollVIew.delegate = self
        scrollVIew.contentSize = biggerSize.size

        createOverlay()
        
        view.addSubview(scrollVIew)
    }
    
    private func createOverlay(){
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: scrollVIew.contentSize.width, height: scrollVIew.contentSize.height))
        var size : CGFloat = 200
        
        if (videoBounds?.size.width)! > (videoBounds?.size.height)! {
            size = (videoBounds?.size.width)!
        }else{
            size = (videoBounds?.size.height)!
        }
        
        let convertedCenter = view.convert(view.center, to: scrollVIew)

        let originX = convertedCenter.x - (size / 4)
        let originY = convertedCenter.y - (size / 4)
        cropRect = CGRect(x: originX, y: originY, width: size / 2 , height: size / 2)
        let cropPath = UIBezierPath(rect: cropRect!)
        path.append(cropPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        
        scrollVIew.center = convertedCenter
        scrollVIew.layer.addSublayer(fillLayer)
    }
}

extension CropOverlayViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("offset!! \(scrollView.contentOffset)")
        cropRect?.origin.x += scrollView.contentOffset.x
        cropRect?.origin.y += scrollView.contentOffset.y
        
        print("result!! \(scrollView.convert(cropRect!, to: view))")

    }
}
