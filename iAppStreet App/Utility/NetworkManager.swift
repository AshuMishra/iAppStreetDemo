//
//  NetworkManager.swift
//  iAppStreet App
//
//  Created by Ashutosh Mishra on 19/07/15.
//  Copyright (c) 2015 Ashutosh Mishra. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

extension Alamofire.Request {
	class func imageResponseSerializer() -> Serializer {
		return { request, response, data in
			if data == nil {
				return (nil, nil)
			}
			
			let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
			
			return (image, nil)
		}
	}
 
	func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
		return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
			completionHandler(request, response, image as? UIImage, error)
		})
	}
}

typealias RequestCompletionBlock = (result: [String]?, error: NSError?) -> ()
typealias ImageDownloadCompletionBlock = (image:UIImage?,error:NSError?) -> ()

let baseURL = "https://api.500px.com/v1/photos/search"
let consumer_key = "h7mEmd23b1Lq38rkE9Kc2fhf2AiFBYDDZOR6orBe"

class NetworkManager {

	let imageCache = NSCache()
	let paginator:Paginator
	
	init () {
		var params = [String: String]()
		params["consumer_key"] = consumer_key
		params["rpp"] = String(18)
		paginator = Paginator(urlString: baseURL, queryParameters: params)
	}

	class var sharedInstance: NetworkManager {
		struct Static {
			static var instance: NetworkManager?
			static var token: dispatch_once_t = 0
		}
		
		dispatch_once(&Static.token) {
			Static.instance = NetworkManager()
		}
		return Static.instance!
	}
	
	func updatePaginator(var category:String) {
		self.paginator.parameters["tag"] = category
	}
	
	func getPhotoUrls(var category:String, completionBlock:RequestCompletionBlock){
//		self.paginator.parameters["tag"] = category
//		self.paginator.loadFirst { (result, error, allPagesLoaded) -> () in
////			completionBlock(result: result, error: error)
//		};)
//		var list = [String]()
//		Alamofire.request(.GET, baseURL, parameters: params, encoding: ParameterEncoding.URL).responseJSON { (request, response, data , error) -> Void in
//			let jsonData = JSON(data!)
//			let photos: Array<JSON> = jsonData["photos"].arrayValue
//			for photo in photos {
//				let dict:Dictionary = photo.dictionaryValue
//				var URLString:String = dict["image_url"]!.stringValue
//				list.append(URLString)
//			}
//			completionBlock(result: list,error: error)
//		}
	}
	
	func downloadImage(urlString:String,completionBlock:ImageDownloadCompletionBlock)-> Request?  {
		let imageURL = NSURL(string: urlString)
		let request:Request? = Alamofire.request(.GET, imageURL!)
		if let image = self.imageCache.objectForKey(imageURL!) as? UIImage {
			completionBlock(image: image, error: nil)
		} else {
			request!.responseImage() {
				(request, _, image, error) in
				if error == nil && image != nil {
					completionBlock(image: image, error: error)
				}
			}
		}
		return request
	}
}

