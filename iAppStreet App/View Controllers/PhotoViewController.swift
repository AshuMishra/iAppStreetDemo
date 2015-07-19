//
//  ViewController.swift
//  iAppStreet App
//
//  Created by Ashutosh Mishra on 18/07/15.
//  Copyright (c) 2015 Ashutosh Mishra. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

	@IBOutlet weak var flickerSearchBar: UISearchBar!
	@IBOutlet weak var flickerCollectionView: UICollectionView!
	
	private var searchArray = [String]()
	
	//MARK: ViewController LifeCycle Methods:-
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		cell.backgroundColor = UIColor.greenColor()
		cell.request?.cancel()
		if (searchArray.count > 0) {
			let urlString:String = searchArray[indexPath.row]
//			cell.configureCell(urlString)
			cell.request = NetworkManager.sharedInstance.downloadImage(urlString, completionBlock: { (image, error) -> () in
				cell.flickerImageview.image = image
			})
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

//	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//		if NetworkManager.sharedInstance.paginator.isCallInProgress {
//			return
//		}
//		 NetworkManager.sharedInstance.paginator.loadNext { (result, error, allPagesLoaded) -> () in
//			self.searchArray = result!
//			self.flickerCollectionView.reloadData()
//		}
//	}
// 
}


//MARK: SearchBar Delegate Methods:-

extension PhotoViewController : UISearchBarDelegate {
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		 println("searching image")
		 self.searchArray.removeAll(keepCapacity: true)
		 NetworkManager.sharedInstance.updatePaginator(searchBar.text)
		 NetworkManager.sharedInstance.paginator.loadFirst { (result, error, allPagesLoaded) -> () in
			self.searchArray = result!
			self.flickerCollectionView.reloadData()
		}
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
			println("load more")
			if (!NetworkManager.sharedInstance.paginator.isCallInProgress) {
						 NetworkManager.sharedInstance.paginator.loadNext { (result, error, allPagesLoaded) -> () in
						 	var prevCount = self.searchArray.count
							var numberOfNewCell = result!.count - prevCount
							self.searchArray = result!
							var indexPaths = [NSIndexPath]()
							for (var i = prevCount ; i < self.searchArray.count ; i++) {
							println("i = \(i)")
								indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
							}
							self.flickerCollectionView.insertItemsAtIndexPaths(indexPaths)
						}

			}
		}
	}
}
