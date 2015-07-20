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
	class func imageDataResponseSerializer() -> Serializer {
		return { request, response, data in
			if data == nil {
				return (nil, nil)
			}
			let resultData:NSData = data!
			return (resultData, nil)
		}

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
	let diskCache: DiskCache = DiskCache.sharedCache()
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
	
	
//	func downloadImage(category:String,urlString:String,completionBlock:ImageDownloadCompletionBlock)-> Request?  {
//		let imageURL = NSURL(string: urlString)
//		if let image = self.imageCache.objectForKey(imageURL!) as? UIImage {
//			completionBlock(image: image, error: nil)
//			return nil
//		} else {
//			let request:Request? = Alamofire.request(.GET, imageURL!)
//			request?.responseImageData({ (request, _, data, error) -> Void in
//				if error == nil && data != nil {
//					self.storeImageToDisk(category, imageData: data!, urlString: urlString)
//					let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
//					self.imageCache.setObject(image!, forKey:urlString)
//					completionBlock(image: image, error: nil)
//				}else {
//					completionBlock(image: nil, error: error)
//				}
//			})
//			return request
//		}
//	}
//  -(NSURL *)asyncableCachesDirectory {
//  NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
//  inDomains:NSUserDomainMask];
//  if ([urls count] > 0) {
//  return [[urls objectAtIndex:0] URLByAppendingPathComponent:self.groupName];
//  }
//  else {
//  return nil;
//  }
//  }
  func downloadImage(category:String,urlString:String,completionBlock:ImageDownloadCompletionBlock)-> Request?  {
    var error: NSError?
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    let documentsDirectory: AnyObject = paths[0]
    let dataPath = documentsDirectory.stringByAppendingPathComponent(category)
    
    if (!NSFileManager.defaultManager().fileExistsAtPath(dataPath)) {
      NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: &error)
    }
    
   return Alamofire.download(.GET, urlString, { temporaryURL, response in
      let fileManager = NSFileManager.defaultManager()
      if let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
        let directory = directoryURL.URLByAppendingPathComponent(category)
        return directory
      }
      return temporaryURL
   }).progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
      println(totalBytesRead)
    }
    .response { request, response, _, error in
      println(response)
    }
  }
  
  
	func storeImageToDisk(category:String,imageData:NSData, urlString:String) {
		DiskCache.sharedCache().groupName = category
		DiskCache.sharedCache().setCache(imageData, forKey: urlString, withGroup: category)
	}
	 
	func getImageFromCacheForURL(category:String,urlString:String)-> UIImage? {
		var imageData:NSData? = self.imageCache.objectForKey(urlString) as? NSData
		if (imageData == nil) {
		    imageData = DiskCache.sharedCache().getCacheForKey(urlString, withGroup: category)
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
	
	func getImageFromSystemCacheForURL(urlString:String)-> UIImage? {
		var image:UIImage? = self.imageCache.objectForKey(urlString) as? UIImage
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
		return image
	}
}

