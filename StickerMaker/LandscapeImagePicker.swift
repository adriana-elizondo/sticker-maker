//
//  LandscapeImagePicker.swift
//  StickerMaker
//
//  Created by Adriana Elizondo on 2018/9/12.
//  Copyright © 2018 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

class LandscapeImagePicker: UIImagePickerController{
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeRight
    }
}
