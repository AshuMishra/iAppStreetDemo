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
	
	class func imageDataResponseSerializer() -> Serializer {
		return { request, response, data in
			if data == nil {
				return (nil, nil)
			}
			let resultData:NSData = data!
			return (resultData, nil)
		}

	}
 
	func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
		return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
			completionHandler(request, response, image as? UIImage, error)
		})
	}
	
	func responseImageData(completionHandler: (NSURLRequest, NSHTTPURLResponse?, NSData?, NSError?) -> Void) -> Self {
		return response(serializer: Request.imageDataResponseSerializer(), completionHandler: { (request, response, data, error) in
			completionHandler(request, response, data as? NSData, error)
		})
	}}

typealias RequestCompletionBlock = (result: [String]?, error: NSError?) -> ()
typealias ImageDownloadCompletionBlock = (image:UIImage?,error:NSError?) -> ()

let baseURL = "https://api.500px.com/v1/photos/search"
let consumer_key = "h7mEmd23b1Lq38rkE9Kc2fhf2AiFBYDDZOR6orBe"

class NetworkManager {

	let imageCache = NSCache()
	let diskCache = DiskCache.sharedCache()
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
	
	
	func downloadImage(category:String,urlString:String,completionBlock:ImageDownloadCompletionBlock)-> Request?  {
		let imageURL = NSURL(string: urlString)
		if let image = self.imageCache.objectForKey(imageURL!) as? UIImage {
			completionBlock(image: image, error: nil)
			return nil
		} else {
			let request:Request? = Alamofire.request(.GET, imageURL!)
			request?.responseImageData({ (request, _, data, error) -> Void in
				if error == nil && data != nil {
					self.storeImage(category, imageData: data!, urlString: urlString)
					let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
					completionBlock(image: image, error: nil)
				}else {
					completionBlock(image: nil, error: error)
				}
			})
			return request
		}
	}
	
	func storeImage(category:String,imageData:NSData, urlString:String) {
		var key = category + "_" + urlString
		imageCache.setObject(imageData, forKey: key)
		DiskCache.sharedCache().setCache(imageData, forKey: urlString, withGroup: category)
//		DiskCache.sharedCache().setCache(imageData, forKey: key)
	}
	
	func getImageFromCacheForURL(category:String,urlString:String)-> UIImage? {
		var imageData:NSData? = self.imageCache.objectForKey(urlString) as? NSData
		if (imageData == nil) {
		imageData = DiskCache.sharedCache().getCacheForKey(urlString, withGroup: category)
//			imageData = DiskCache.sharedCache().getCacheForKey(urlString)
			if let data = imageData {
				println("image from disk")
				imageCache.setObject(data, forKey: urlString)
			}
		}else {
			println("image from memory")
		}

		if let data = imageData {
			return UIImage(data: imageData!)
		}else {
			return nil
		}
	}
	
	func getImageFromCacheForURL(urlString:String)-> UIImage? {
//		var imageData:NSData? = self.imageCache.objectForKey(urlString) as? NSData
//		if (imageData == nil) {
//			imageData = DiskCache.sharedCache().getCacheForKey(urlString)
//			if let data = imageData {
//				println("image from disk")
//				imageCache.setObject(data, forKey: urlString)
//			}
//		}else {
//			println("image from memory")
//		}
//		
//		if let data = imageData {
//			return UIImage(data: imageData!)
//		}else {
//			return nil
//		}
		return DiskCache.sharedCache().imageForKey(urlString)
	}
}

