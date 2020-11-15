//
//  PlaylistsViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/20/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import CoreData

class PlaylistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer {
        didSet {
            //updateTableView()
        }
    }

    var fetchedResultsController: NSFetchedResultsController<Playlist> {
        let context = AppDelegate.viewContext
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "")!
        let obj = fetchedResultsController.object(at: indexPath)

        cell.textLabel?.text = obj.title
        cell.textLabel?.textColor = mainRed

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = fetchedResultsController.object(at: indexPath)
        let songsFetchedResults = CoreDataUtils.fetchSongs(context: AppDelegate.viewContext, predicate: CoreDataUtils.playlistSongsPredicate(playlist: playlist))
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
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
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
    
    
    @IBAction func goToCreatePlaylist(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCreatePlaylist", sender: self)
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
