//
//  CustomFlickerCell.swift
//  iAppStreet App
//
//  Created by Ashutosh Mishra on 18/07/15.
//  Copyright (c) 2015 Ashutosh Mishra. All rights reserved.
//

import UIKit
import Alamofire

class CustomFlickerCell: UICollectionViewCell {

	@IBOutlet weak var flickerImageview: UIImageView!
	var request: Alamofire.Request?
	var isExpanded:Bool = false
}
