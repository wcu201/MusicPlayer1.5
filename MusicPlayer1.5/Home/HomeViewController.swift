//
//  HomeViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 3/30/19.
//  Copyright © 2019 William  Uchegbu. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var recentlyAddedCollection: UICollectionView!

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var recentlyAddedFetchedResultsController: NSFetchedResultsController<Song>?
    
    
    let sections = ["Songs", "Artists", "Albums", "Playlists"]
    let sectionImages = [#imageLiteral(resourceName: "outline_library_music_black_36dp"),#imageLiteral(resourceName: "baseline_recent_actors_black_48dp"),#imageLiteral(resourceName: "baseline_album_black_36dp"),#imageLiteral(resourceName: "outline_playlist_play_black_36dp")]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
            case collection:
                return sections.count
            case recentlyAddedCollection:
                return recentlyAddedFetchedResultsController?.fetchedObjects?.count ?? 0
            default:
                return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case collection:
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
            
            let img = resizeImage(image: sectionImages[indexPath.row], targetSize: CGSize(width: 20, height: 20))
            cell.icon.image = img
            cell.icon.image = img.withRenderingMode(.alwaysTemplate)
            cell.icon.tintColor = UIColor.white
            cell.label.text = sections[indexPath.row]
            cell.backgroundColor = UIColor(red: 41/255, green: 45/255, blue: 51/255, alpha: 1.0)
            return cell
        case recentlyAddedCollection:
            let cell = recentlyAddedCollection.dequeueReusableCell(withReuseIdentifier: "recentlyAddedCell", for: indexPath) as! RecentlyAddedCollectionViewCell
            let song = recentlyAddedFetchedResultsController?.object(at: indexPath)
            if let imageData = song?.artwork {
                cell.artwork.image = UIImage(data: imageData)
            }
            //cell.artwork.image = getImage(songURL: appDelegate.downloadLibrary[appDelegate.downloadLibrary.count-indexPath.row-1])
            return cell
        default:
            return UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
            case collection:
                switch indexPath.row {
                    case 0:
                        let songsFetchedResults = CoreDataUtils.fetchSongs(context: AppDelegate.viewContext, onlyCompletedDownloads: true, predicate: nil)
                        if let vc = appDelegate.songsVC {
                            vc.useCoreData = true
                            vc.fetchedResultsController = songsFetchedResults
                            vc.fetchedResultsController?.delegate = vc
                            //appDelegate.selectedLibrary = appDelegate.downloadLibrary
                            show(vc, sender: self)
                        }
                        else {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "songs") as! ViewController
                            vc.useCoreData = true
                            vc.fetchedResultsController = songsFetchedResults
                            vc.fetchedResultsController?.delegate = vc
                            //appDelegate.selectedLibrary = appDelegate.downloadLibrary
                            appDelegate.songsVC = vc
                            self.navigationController?.pushViewController(vc, animated: true)
                    }
                    case 1:
                        self.performSegue(withIdentifier: "goToArtists", sender: self)
                    case 2:
                        self.performSegue(withIdentifier: "goToAlbums", sender: self)
                    case 3:
                        self.performSegue(withIdentifier: "goToPlaylists", sender: self)
                    default:
                        break
                }
            case recentlyAddedCollection:
                break
            default:
                break
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height*0.9
        return CGSize(width: height, height: height)
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if controller == recentlyAddedFetchedResultsController {
            switch type {
                case .insert:
                    if let indexPath = newIndexPath {
                        recentlyAddedCollection.insertItems(at: [indexPath])
                    }
                    break
                case .delete:
                    if let indexPath = indexPath {
                        recentlyAddedCollection.deleteItems(at: [indexPath])
                    }
                    break
                case .update:
                    recentlyAddedCollection.reloadItems(at: [indexPath!])
                    break
                default:
                    print("...")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        
        recentlyAddedCollection.delegate = self
        recentlyAddedCollection.dataSource = self
        
        refresh(v: self.view)
        collection.backgroundColor = UIColor.clear
        recentlyAddedCollection.backgroundColor = UIColor.clear
        
        recentlyAddedFetchedResultsController = CoreDataUtils.fetchSongs(context: AppDelegate.viewContext, onlyCompletedDownloads: true, predicate: CoreDataUtils.recentlyAddedPredicate())
        recentlyAddedFetchedResultsController?.delegate = self
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        setupConstraints()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupConstraints() {
        self.view.addConstraints([
            NSLayoutConstraint(item: collection!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.25, constant: 0),
            //NSLayoutConstraint(item: collection!, attribute: <#T##NSLayoutConstraint.Attribute#>, relatedBy: <#T##NSLayoutConstraint.Relation#>, toItem: <#T##Any?#>, attribute: <#T##NSLayoutConstraint.Attribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>)
        ])
        
        self.view.addConstraints([
            NSLayoutConstraint(item: recentlyAddedCollection!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.2, constant: 0),
        ])
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
