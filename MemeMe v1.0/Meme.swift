//
//  Meme.swift
//  MemeMe v1.0
//
//  Created by Kevin Lu on 24/11/2015.
//  Copyright (c) 2015 Kevin Lu. All rights reserved.
//

import Foundation
import UIKit
struct Meme {
    var topTextFieldString: String
    var bottomTextFieldString: String
    var originalImage: UIImage
    var memeImage: UIImage
    init (topTextFieldString: String, bottomTextFieldString: String, originalImage: UIImage, memeImage: UIImage) {
        self.topTextFieldString = topTextFieldString
        self.bottomTextFieldString = bottomTextFieldString
        self.originalImage = originalImage
        self.memeImage = memeImage
    }
    
}