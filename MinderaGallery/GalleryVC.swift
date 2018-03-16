//
//  GalleryVC.swift
//  MinderaGallery
//
//  Created by Quentin Beaudouin on 14/03/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit
import AlamofireImage


class GalleryVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var photos:[FlickrPhoto]?
    
    var spaceCellToEdge:CGFloat = 2
    var spaceBetweenCells:CGFloat = 2
    var currentPageNumber = 1 // start at page 1
    var isCurrentPageLoaded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configCollectionView()
        
        photos = APIConnector.getSearchPhotosCached()
        collectionView.reloadData()
        
        callAPIPhotos()
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//************************************
// MARK: - Initial Configuration
//************************************

extension GalleryVC {
    
    func configCollectionView() {
        
        let nameAndId = PictureCollectionCell.nameAndId
        collectionView.register(UINib(nibName: nameAndId, bundle: nil), forCellWithReuseIdentifier: nameAndId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
    }
    
}

//************************************
// MARK: - API calls
//************************************

extension GalleryVC {
    
    func callAPIPhotos(){
        
        isCurrentPageLoaded = false
        APIConnector.getSearchPhotos(page: currentPageNumber, completion: {[weak self] photos, error in
            
            if photos == nil {
                self?.isCurrentPageLoaded = true
                self?.showNetworkAlert()
                return
            }
            
            if self?.photos == nil {
                self?.photos = photos
            }
            else {
                //for offline not having the same photo twice
                for photo in photos! {
                    if !self!.photos!.contains(photo) {
                        self?.photos?.append(photo)
                    }
                }
                //self?.photos?.append(contentsOf: photos!)
            }
            
            self?.collectionView.reloadData()
            self?.isCurrentPageLoaded = true
            self?.currentPageNumber += 1
        })
        
        //print("current page number", currentPageNumber)
    }
    
}


//************************************
// MARK: - collection view Data source
//************************************

extension GalleryVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionCell.nameAndId, for: indexPath) as! PictureCollectionCell
        
        if let unwrappedPhotos = photos, unwrappedPhotos.count > indexPath.row {
            let photo = unwrappedPhotos[indexPath.row]
            cell.picture.af_setImage(withURL: photo.largeSquareUrl, placeholderImage: #imageLiteral(resourceName: "defaultPhoto"))
        }

        
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos == nil ? 0 : photos!.count
    }
    
    
}

//************************************
// MARK: - collection view Delegate
//************************************

extension GalleryVC: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        showPicturesVC(fromCollection: collectionView, indexPath: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
}

//************************************
// MARK: - collection view Delegate FlowLayout
//************************************

/* COMMENT:
 * I didn't use the storyboard properties for the layout as I find it more readable this way.
 */

extension GalleryVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let nbCellPerRow:CGFloat = 2.0
        
        let cellWidth:CGFloat = (UIScreen.main.bounds.size.width - 2 * spaceCellToEdge - (nbCellPerRow - 1) * spaceBetweenCells)/nbCellPerRow;
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spaceCellToEdge, left: spaceCellToEdge, bottom: spaceCellToEdge, right: spaceCellToEdge)
    }
}

//************************************
// MARK: - Navigation
//************************************

extension GalleryVC {
    
    func showPicturesVC(fromCollection collectionView:UICollectionView, indexPath:IndexPath) {
        
        let insPhotos = photos!.map({ (photo) -> INSPhotoViewable in
            return INSPhoto(imageURL: photo.largeUrl, thumbnailImageURL: photo.largeSquareUrl)
        })
        
        
        let currentPhoto = insPhotos[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        
        let galleryPreview = INSPhotosViewController(photos: insPhotos, initialPhoto: currentPhoto, referenceView: cell)
        
        galleryPreview.didDismissHandler = { galleryPreviewVC in
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { photo in
            if let index = insPhotos.index(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath)
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
        
    }
    
    func showNetworkAlert() {
        
        if !Reachability.isConnectedToNetwork(), photos == nil {
            
            let alert = Bundle.main.loadNibNamed("Popup", owner: self, options: nil)?[0] as! Popup
            alert.frame = (self.view.window?.bounds)!
            
            
            alert.tapBackgroundToDismiss = false
            
            alert.setup(title: "No Internet connection",
                        message: "Check your internet connection and try again 😎",
                        leftButtonTitle: "Try again!")
            
            alert.leftAction = { [weak self] in
                self?.callAPIPhotos()
            }
            
            alert.showInWindow(self.view.window!)
        }
        
    }
    
}

//************************************
// MARK: - Scroll table Delegate
//************************************

extension GalleryVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollDistanceToBot = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height
        
        //load next page when only 2 full screens remain to show
        let preloadingMargin = 2 * scrollView.frame.size.height
        
        if scrollDistanceToBot < preloadingMargin, isCurrentPageLoaded {
            callAPIPhotos()
        }

        
    }
    
}


