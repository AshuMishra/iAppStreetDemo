//
//  Paginator.swift
//  iAppStreet App
//
//  Created by Ashutosh Mishra on 19/07/15.
//  Copyright (c) 2015 Ashutosh Mishra. All rights reserved.
//

import Foundation
import UIKit
import IJReachability
import Alamofire
import SwiftyJSON

class Paginator: NSObject {
	
	var url: String
	var parameters: [String:String]
	private var finalResult: [String]
	var pageCount = 0
	var nextPageToken: NSString?
	var isCallInProgress:Bool = false
	var allPagesLoaded:Bool = false
	
	typealias RequestCompletionBlock = (result: [String]?, error: NSError?,allPagesLoaded:Bool) -> ()
	
	init(urlString:NSString,queryParameters:[String:String]?) {
		url = urlString as String
		parameters = queryParameters!
		finalResult = [String]()
	}
	
	func reset() {
		self.pageCount = 0
		self.finalResult = []
	}
	
	func shouldLoadNext()-> Bool {
		return !(allPagesLoaded && isCallInProgress)
	}
	
	func loadFirst(completionBlock:RequestCompletionBlock) {
		//Load the first page of search results
		
		var checkInternetConnection:Bool = IJReachability.isConnectedToNetwork()
		if checkInternetConnection {
			self.reset()
			
			var params = parameters
			let page = 1
			params["page"] = String(page)
			self.finalResult = [String]()
			isCallInProgress = false
			

			HUDController.sharedController.contentView = HUDContentView.ProgressView()
			HUDController.sharedController.show()
			
			Alamofire.request(.GET, baseURL, parameters: params, encoding: ParameterEncoding.URL).responseJSON { (request, response, data , error) -> Void in
			if data != nil {
				let jsonData = JSON(data!)
				let photos: Array<JSON> = jsonData["photos"].arrayValue
				for photo in photos {
					let dict:Dictionary = photo.dictionaryValue
					var URLString:String = dict["image_url"]!.stringValue
					self.finalResult.append(URLString)
				}
				HUDController.sharedController.hide(animated: true)
				completionBlock(result: self.finalResult,error: error,allPagesLoaded:false)
				self.isCallInProgress = false
			}else {
				HUDController.sharedController.hide(animated: true)
			}
			}
		}else {
			
//			self.showNetworkError()
			HUDController.sharedController.hide(animated: true)
			var error = NSError(domain: "Network error", code: 1, userInfo: nil)
			completionBlock(result: nil, error: error, allPagesLoaded: false)
			isCallInProgress = false
		}
		
	}
	
	func showNetworkError() {
		UIAlertView(title: "Error", message: "Device is not connected to internet. Please check connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
	}

	func loadNext(completionBlock:RequestCompletionBlock) {
		if (self.isCallInProgress) {return}
		var checkInternetConnection:Bool = IJReachability.isConnectedToNetwork()
		if checkInternetConnection {
			var params = parameters
			self.pageCount =  self.pageCount + 1
			params["page"] = String(self.pageCount)
			isCallInProgress = true
			Alamofire.request(.GET, baseURL, parameters: params, encoding: ParameterEncoding.URL).responseJSON { (request, response, data , error) -> Void in
				let jsonData = JSON(data!)
				let photos: Array<JSON> = jsonData["photos"].arrayValue
				for photo in photos {
					let dict:Dictionary = photo.dictionaryValue
					var URLString:String = dict["image_url"]!.stringValue
					self.finalResult.append(URLString)
				}
				completionBlock(result: self.finalResult,error: error,allPagesLoaded:false)
				self.isCallInProgress = false
			}
			
		}else {
//			self.showNetworkError()
			completionBlock(result: self.finalResult, error: nil, allPagesLoaded: false)
			isCallInProgress = false
		}
	  }
	
}