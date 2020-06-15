//
//  AlbumsViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/24/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit
import CoreData

class AlbumsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer {
        didSet {
            updateCollectionView()
        }
    }
    var selectedLibrary = [URL]()
    var albumDictionary: [String : [URL]] {
        var dict = [String: [URL]]()
        
        for song in userData.downloadLibrary {
            if dict[getAlbum(songURL: song)] != nil {
                dict[getAlbum(songURL: song)]?.append(song)
            }
            else {
                dict[getAlbum(songURL: song)] = [song]
            }
        }
        
        return dict
    }
    
    var fetchedResultsController: NSFetchedResultsController<Album> {
        let context = AppDelegate.viewContext
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        let sortDescriptor = NSSortDescriptor(
            key: "title",
            ascending: true,
            selector: #selector(NSString.localizedCompare(_:)))
        request.sortDescriptors = [sortDescriptor]
        request.predicate = nil
        let albums = try? context.fetch(request)
        
        let resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil /*"AlbumCache"*/)
        
        do {
            try resultsController.performFetch()
        }
        catch {
           fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        return resultsController
    }

    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    var currentLibrary = [URL]()
    
    func updateCollectionView() {
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        }
        return 0
        //return self.appDelegate.albumLibraries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
        //return cell
        let obj = fetchedResultsController.object(at: indexPath)
            
        cell.album.text = obj.title
        cell.artist.text = obj.albumArtist?.title
        
        if let data = (obj.songs?.allObjects.first as! Song).artwork {
            let image = UIImage(data: data)
            cell.artwork.image = image
        }
        
        
        
        return cell
//        var keys = Array(appDelegate.albumLibraries.keys)
//        keys.sort()
//        let firstSong = appDelegate.albumLibraries[keys[indexPath.row]]![0]
//        let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
//        cell.artist.text = getArtist(songURL: firstSong)
//        cell.album.text = getAlbum(songURL: firstSong)
//        cell.artwork.image = getImage(songURL: firstSong)
//        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Should change logic
//        var keys = Array(albumDictionary.keys)
//        keys.sort()
//        selectedLibrary = albumDictionary[keys[indexPath.row]]!
//
//
//        appDelegate.selectedLibrary = selectedLibrary
//        let destination: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "songs") as! ViewController
//        self.present(destination, animated: true, completion: nil)
//        //_ = UIStoryboardSegue(identifier: "showSongs", source: self, destination: ViewController())
//        //performSegue(withIdentifier: "showSongs", sender: self)
    }
    
    
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.delegate = self
        //albumsCollectionView.dataSource = fetchedResultsController as? UICollectionViewDataSource
        
        albumsCollectionView.delegate = self
        albumsCollectionView.reloadData()
        //print("Album: ", albumKeys)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
 cell.album2Art.isUserInteractionEnabled = true
 cell.album2Art.restorationIdentifier = albumKeys[indexPath.row * 2 + 1]
 let tapGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(self.showSongs))
 */
    @objc func showSongs(/*sender: UIImageView*/) {
        print("Picture Pressed")
        //selectedLibrary = albumDictionary[sender.restorationIdentifier!]!
        //performSegue(withIdentifier: "showAlbumSongs", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appDelegate.selectedLibrary = selectedLibrary
    }
}
