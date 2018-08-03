//
//  Constants.swift
//  StickerMaker
//
//  Created by Adriana Elizondo on 2018/8/2.
//  Copyright © 2018 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
   static var isIphoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    
   static var isIphone5: Bool {
        return UIScreen.main.bounds.size.height == 568.0
    }
    
    static var navBarHeight : CGFloat{
        guard !isIphoneX else {
            return 84
        }
        
        return 44
    }
    
    static var statusBarHeight : CGFloat{
        guard !isIphoneX else {
            return 44
        }
        
        return 20
    }
}


extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}
