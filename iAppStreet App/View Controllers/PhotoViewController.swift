//
//  ViewController.swift
//  iAppStreet App
//
//  Created by Ashutosh Mishra on 18/07/15.
//  Copyright (c) 2015 Ashutosh Mishra. All rights reserved.
//

import UIKit
import IJReachability

class PhotoViewController: UIViewController,UICollectionViewDelegateFlowLayout {

	@IBOutlet weak var flickerSearchBar: UISearchBar!
	@IBOutlet weak var flickerCollectionView: UICollectionView!
	
	private var searchArray = [String]()
	let imageCache = NSCache()
	let flickerFooterViewIdentifier = "flickerCollectionFooterFooterView"
	
	//MARK: ViewController LifeCycle Methods:-
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.initialSetup()
				// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}



//MARK: Custom Action Methods:-

func initialSetup() {
	let layout = UICollectionViewFlowLayout()
	layout.footerReferenceSize = CGSize(width: self.flickerCollectionView!.bounds.size.width, height: 100.0)
	self.flickerCollectionView!.registerClass(CollectionViewLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: flickerFooterViewIdentifier)
	
	self.flickerCollectionView!.collectionViewLayout = layout
	self.flickerCollectionView.hidden = true
	self.view.backgroundColor = UIColor.blackColor()
 }

}

//MARK: Data source  methods of UICollectionView
extension PhotoViewController : UICollectionViewDataSource {
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.searchArray.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let reuseIdentifier = "cellIdentifier"
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomFlickerCell
		
		if (searchArray.count > 0) {
			let urlString:String = searchArray[indexPath.row]
			var image: UIImage?
			if IJReachability.isConnectedToNetwork() {
				 image = NetworkManager.sharedInstance.getImageFromSystemCacheForURL(urlString)
			}
			else {
				 image = NetworkManager.sharedInstance.getImageFromCacheForURL(self.flickerSearchBar.text, urlString: urlString)
			}
			cell.request?.cancel()

			if (image != nil) {
				cell.flickerImageview.image = image
			}
			else {
			     	cell.flickerImageview.image = nil
					cell.request = NetworkManager.sharedInstance.downloadImage(self.flickerSearchBar.text, urlString:urlString, completionBlock: { (image, error) -> () in
						if image != nil {
							cell.flickerImageview.image = image
							self.imageCache.setObject(image!, forKey:urlString)
						}
						
					})
				
			}
		}
		
		// Configure the cell
		return cell
	}
}

//MARK: delegate methods of UICollectionView
extension PhotoViewController : UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let intercellDistance:Int = 10
		let inset:Int = 10
		let numberOfCellPerRow:Int = 3
		let width = Int(UIScreen.mainScreen().bounds.size.width) - (intercellDistance * (numberOfCellPerRow-1)+inset * 2)
		return CGSizeMake(CGFloat(width / numberOfCellPerRow), CGFloat(width / numberOfCellPerRow))
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(10,10, 0,10)
	}
}

extension PhotoViewController : UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
	
var footer =  self.flickerCollectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: flickerFooterViewIdentifier, forIndexPath: indexPath) as! UICollectionReusableView
	if !IJReachability.isConnectedToNetwork() {
		footer.hidden = true

	}else {
		footer.hidden = false

	}
	return footer
	}
	
	}

class CollectionViewLoadingCell: UICollectionReusableView {
	let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		spinner.startAnimating()
		spinner.center = self.center
		addSubview(spinner)
	}
}
//MARK: SearchBar Delegate Methods:-

extension PhotoViewController : UISearchBarDelegate {
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		 self.searchArray.removeAll(keepCapacity: true)
		 NetworkManager.sharedInstance.updatePaginator(searchBar.text)
		 NetworkManager.sharedInstance.paginator.loadFirst { (result, error, allPagesLoaded) -> () in
		 if (error == nil) {
			self.searchArray = result!
			self.flickerCollectionView.hidden = false
			self.flickerCollectionView.reloadData()
		}
		else {
		    self.flickerCollectionView.hidden = false
			NetworkManager.sharedInstance.paginator.isCallInProgress = false
			var tempArray: NSArray? = NetworkManager.sharedInstance.diskCache.allKeys(searchBar.text) as? [String]
			if tempArray?.count>0 {
				self.searchArray = NetworkManager.sharedInstance.diskCache.allKeys(searchBar.text) as! [String]
			}
			else {
				self.searchArray.removeAll(keepCapacity: false)
				UIAlertView(title: "Error", message: "No record found", delegate: nil, cancelButtonTitle: "OK").show()
			}
			self.flickerCollectionView.reloadData()
		}
	  }
	}
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		 self.flickerSearchBar.text = ""
		 self.flickerSearchBar.resignFirstResponder()
	}
}

//MARK: ScrollView Delegate Methods:-
extension PhotoViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
	    self.flickerSearchBar.resignFirstResponder()
		var offset = scrollView.contentOffset;
		var bounds = scrollView.bounds;
		var size = scrollView.contentSize;
		var inset = scrollView.contentInset;
		var y = offset.y + bounds.size.height - inset.bottom;
		var h = size.height;
		var reload_distance:CGFloat = 10.0;
		if(y > (size.height + reload_distance)) {
			if (!NetworkManager.sharedInstance.paginator.isCallInProgress) {
						 NetworkManager.sharedInstance.paginator.loadNext { (result, error, allPagesLoaded) -> () in
						 	var prevCount = self.searchArray.count
							var numberOfNewCell = result!.count - prevCount
							self.searchArray = result!
							var indexPaths = [NSIndexPath]()
							for (var i = prevCount ; i < self.searchArray.count ; i++) {
								indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
							}
							if indexPaths.count>0 {
								self.flickerCollectionView.insertItemsAtIndexPaths(indexPaths)
							}
						}

			}
		}
	}
}
