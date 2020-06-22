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
    
    var fetchedResultsController: NSFetchedResultsController<Album> = {
        let context = AppDelegate.viewContext
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        let sortDescriptor = NSSortDescriptor(
            key: "title",
            ascending: true,
            selector: #selector(NSString.localizedCompare(_:)))
        request.sortDescriptors = [sortDescriptor]
        request.predicate = nil
        //let albums = try? context.fetch(request)
        
        let resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil /*"AlbumCache"*/)
        
        do {
            try resultsController.performFetch()
        }
        catch {
           fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        return resultsController
    }()

    
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
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
        let obj = fetchedResultsController.object(at: indexPath)
            
        cell.album.text = obj.title
        cell.artist.text = obj.albumArtist?.title
        
        if let data = (obj.songs?.firstObject as! Song).artwork {
            let image = UIImage(data: data)
            cell.artwork.image = image
        }
 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let album = fetchedResultsController.object(at: indexPath)
            let songsFetchedResults = CoreDataUtils.fetchSongs(context: AppDelegate.viewContext, predicate: CoreDataUtils.albumSongsPredicate(album: album))
            if let vc = appDelegate.songsVC {
                vc.useCoreData = true
                vc.fetchedResultsController = songsFetchedResults
                show(vc, sender: self)
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "songs") as! ViewController
                vc.useCoreData = true
                vc.fetchedResultsController = songsFetchedResults
                appDelegate.songsVC = vc
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width/3.0
        let height = width

        return CGSize(width: width, height: height)
    }
    
    
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                if let indexPath = newIndexPath {
                    albumsCollectionView.insertItems(at: [indexPath])
                }
                break
            case .delete:
                if let indexPath = indexPath {
                    albumsCollectionView.deleteItems(at: [indexPath])
                }
                break
            case .update:
                albumsCollectionView.reloadItems(at: [indexPath!])
                break
            default:
                print("...")
        }
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func showSongs() {
        //print("Picture Pressed")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
