//
//  ArtistsViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/24/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import CoreData

class ArtistsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer {
        didSet {
            //updateTableView()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<Artist> {
        let context = AppDelegate.viewContext
        let request: NSFetchRequest<Artist> = Artist.fetchRequest()
        let sortDescriptor = NSSortDescriptor(
            key: "title",
            ascending: true,
            selector: #selector(NSString.localizedCompare(_:)))
        request.sortDescriptors = [sortDescriptor]
        request.predicate = nil
        //let artists = try? context.fetch(request)
        
        let resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil /*"AlbumCache"*/)
        
        do {
            try resultsController.performFetch()
        }
        catch {
           fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        return resultsController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell")!
        let obj = fetchedResultsController.object(at: indexPath)
                   
        cell.textLabel?.text = obj.title
        cell.textLabel?.textColor = mainRed
               
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = fetchedResultsController.object(at: indexPath)
        let songsFetchedResults = CoreDataUtils.fetchSongs(context: AppDelegate.viewContext, onlyCompletedDownloads: true, predicate: CoreDataUtils.artistSongsPredicate(artist: artist))
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
        
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchedResultsController.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
