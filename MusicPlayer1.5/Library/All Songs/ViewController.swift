//
//  ViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 9/3/17.
//  Copyright © 2017 William  Uchegbu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData
import ID3TagEditor

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AVAudioPlayerDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nowPlaying: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var currentSong: URL?
    var isSearching: Bool = false
    var selectedSong: URL?
    var currentLibray = [URL]()
    var useCoreData: Bool = false
    var fetchedResultsController: NSFetchedResultsController<Song>?
    
    override func viewWillAppear(_ animated: Bool) {
        //isSearching = false
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        if useCoreData {
            fetchedResultsController!.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {isSearching = false}
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {isSearching = false}
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {isSearching = false}
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        userData.filteredMap.removeAll()
//        userData.filteredLibrary.removeAll()
//        userData.filteredPositions.removeAll()
//        for (index, song) in (currentLibray.enumerated()){
//            if (getTitle(songURL: song).lowercased()).range(of: searchText.lowercased()) != nil {
//                userData.filteredMap[index] = song
//                userData.filteredLibrary.append(song)
//                userData.filteredPositions.append(index)
//            }
//        }
//
//        if(userData.filteredMap.isEmpty) {isSearching = false}
//        else {isSearching = true}
//
//        if(userData.filteredLibrary.isEmpty) {isSearching = false}
//        else {isSearching = true}
//        self.tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if useCoreData, let results = fetchedResultsController {
            return (results.sections?.count ?? 1) + 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if useCoreData, let results = fetchedResultsController {
            switch section {
                case 0:
                    return 1
                case 1:
                    if let sections = results.sections, sections.count > 0 {
                        // Should fix logic
                        return sections[0].numberOfObjects
                    }
                default:
                    return 0
            }
        }
        switch section {
            case 0:
                return 1
            case 1:
                //if isSearching{return userData.filteredLibrary.count}
                return appDelegate.currentPlaylist.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "shuffleCell") as? ShuffleTableViewCell
            cell?.shuffleBTN.addTarget(self, action: #selector(shufflePlay), for: .touchUpInside)
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? songTableViewCell
        
            if useCoreData, let results = fetchedResultsController {
                let song = results.object(at: IndexPath(row: indexPath.row, section: 0))

                cell?.artwork.image = #imageLiteral(resourceName: "album-cover-placeholder-light")
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    //let url = self.appDelegate.selectedLibrary[indexPath.row]

                    let title = song.title
                    let artist = song.songArtist?.title
                    DispatchQueue.main.async {
                        if let data = song.artwork {
                            let image = UIImage(data: data)
                            cell!.artwork.image = image
                        }
                        cell?.titleText.text = title
                        cell?.artistText.text = artist
                    }
                }

                return cell!
            }
            
            if isSearching {
                // Ignore until I fix searching
                cell?.titleText.text = getTitle(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.artistText.text = getArtist(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.artwork.image = getImage(songURL: (userData.filteredLibrary[indexPath.row]))
                cell?.editBTN.setTitle(userData.filteredLibrary[indexPath.row].absoluteString, for: .normal)
                cell?.editBTN.addTarget(self, action: #selector(goToMetadataVC), for: .touchUpInside)
            }
            else {
                // This helps against tableview scroll slowdown but makes a weird effect when scrolling fast. I consider this an improvment from the previous behavior but can definitely be improved upon
                cell?.artwork.image = #imageLiteral(resourceName: "album-cover-placeholder-light")
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else {
                      return
                    }
                    let url = (self.appDelegate.currentPlaylist[indexPath.row] as! Song).getURL()!
                     
                    let image = getImage(songURL: url)
                    let title = getTitle(songURL: url)
                    let artist = getArtist(songURL: url)
                    DispatchQueue.main.async {
                        cell?.artwork.image = image
                        cell?.titleText.text = title
                        cell?.artistText.text = artist
                    }
                }
                
                cell?.editBTN.setTitle((appDelegate.currentPlaylist[indexPath.row] as! Song).getURL()!.absoluteString, for: .normal)
                cell?.editBTN.addTarget(self, action: #selector(goToMetadataVC), for: .touchUpInside)
            }
        
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "")
            return cell!
        }
    }
    
    @objc func goToMetadataVC(sender: UIButton){
        let url = URL(string: sender.currentTitle!)
        selectedSong = url!
        print("URL: ", url!)
        self.performSegue(withIdentifier: "goToMetadata", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
            if useCoreData {
                if let results = fetchedResultsController {
                    appDelegate.currentPlaylist = NSMutableOrderedSet(array: results.fetchedObjects ?? [])
                    let url = results.object(at: IndexPath(row: indexPath.row, section: 0)).getURL()
                    appDelegate.arrayPos = indexPath.row
                    
                    do {
                        AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf: url!)
                    }
                    catch {
                        
                    }
                    
                    AppDelegate.sharedPlayer.delegate = appDelegate
                    AppDelegate.sharedPlayer.prepareToPlay()
                    AppDelegate.sharedPlayer.play()
                    
                    if appDelegate.playerVC == nil {
                        //No Music Player exists, so some setup needs to be done
                        MusicController().attachToCommandCenter()
                        let vc = MusicPlayerViewController(songURL: url!)
                        appDelegate.playerVC = vc
                        vc.modalPresentationStyle = .popover
                    }

                    self.present(appDelegate.playerVC!, animated: true, completion: nil)
                }
                return 
            }
            
            //appDelegate.currentPlaylist = NSMutableOrderedSet(array: appDelegate.selectedLibrary)
            currentSong = (appDelegate.currentPlaylist[indexPath.row] as! URL)
            //currentSong = appDelegate.selectedLibrary[indexPath.row]
            appDelegate.arrayPos = indexPath.row
        
            do {AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf:
                (appDelegate.currentPlaylist[indexPath.row] as! URL)
                //appDelegate.selectedLibrary[indexPath.row]
                )}
            catch{
                // TODO: Handle URL Error
            }
            
            AppDelegate.sharedPlayer.delegate = appDelegate
            AppDelegate.sharedPlayer.prepareToPlay()
            AppDelegate.sharedPlayer.play()
            appDelegate.musicPlaying = true
            appDelegate.songPlaying = currentSong
            
            musicVC.isShuffled = false
            

            if appDelegate.playerVC == nil {
                //No Music Player exists, so some setup needs to be done
                MusicController().attachToCommandCenter()
                let vc = MusicPlayerViewController(songURL: currentSong!)
                appDelegate.playerVC = vc
                vc.modalPresentationStyle = .popover
            }

            self.present(appDelegate.playerVC!, animated: true, completion: nil)
            

        /*
        if(isSearching){
            //MvC.url = (userData.filteredLibrary[indexPath.row])
            currentSong = (userData.filteredLibrary[indexPath.row])
            //musicVC.songVC = MvC
            musicVC.playerExists = true
            musicVC.arrayPos = userData.filteredPositions[indexPath.row]
            populateNowPlayBar(url: currentSong!)
            (musicVC.nav.viewControllers[0] as! LibraryViewController).populateNowPlyingBar(url: currentSong!)
            do {
                musicVC.player = try AVAudioPlayer(contentsOf: (userData.filteredLibrary[indexPath.row]))
            }
            catch{print("Song does not exist.")}
            isSearching = false
            searchBar.text = ""
            searchBar.endEditing(true)
            musicVC.player?.prepareToPlay()
            musicVC.player?.play()
        }
 */
        }
 
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    // DEPRECATED FOR NOW
    @IBAction func nowPlaying(_ sender: Any) {
        //show(appDelegate.playerVC!, sender: self)
    }

    func showNowPlaying(){
      nowPlaying.isHidden = false
      nowPlaying.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let song = fetchedResultsController?.object(at: IndexPath(row: indexPath.row, section: 0))
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: {(action, other) in
            openBoolAlert(title: "Delete Song", message: "Can't delete"/*"Are you sure you want to delete this song?"*/, view: self, action: {() in
//                guard let selectedSong = song else {return}
//                print("Action Called: Delete", self.appDelegate.downloadLibrary[indexPath.row])
//                self.appDelegate.deleteFromLibrary(url: selectedSong.getURL()!)
//                tableView.reloadData()
            })
        })
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: {(action, other) in
            guard let selectedSong = song else {return}
            self.selectedSong = selectedSong.getURL()!
            self.performSegue(withIdentifier: "goToMetadata", sender: self)
        })
        
        deleteAction.backgroundColor = UIColor.red
        editAction.backgroundColor = UIColor.blue
        
        return [deleteAction, editAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMetadata" {
            let vc = segue.destination as? MetadataViewController
            vc?.songURL = selectedSong
        }
        
    }

    @objc func shufflePlay() {
        if (!(fetchedResultsController?.fetchedObjects!.isEmpty)!){
            AppDelegate.sharedPlayer.stop()
            appDelegate.currentUnshuffledPlaylist = NSMutableOrderedSet(array: fetchedResultsController?.fetchedObjects! ?? [])
            appDelegate.currentPlaylist = NSMutableOrderedSet(array: fetchedResultsController?.fetchedObjects!.shuffled() ?? [])
            
            let song = appDelegate.currentPlaylist[0] as! Song
            appDelegate.arrayPos = 0
            
            do {
                AppDelegate.sharedPlayer = try AVAudioPlayer(contentsOf: song.getURL()!)
            }
            catch {
                // TODO: Handle URL error
            }
            
            AppDelegate.sharedPlayer.delegate = appDelegate
            AppDelegate.sharedPlayer.prepareToPlay()
            AppDelegate.sharedPlayer.play()
            appDelegate.musicPlaying = true
            
            if appDelegate.playerVC == nil {
                //No Music Player exists, so some setup needs to be done
                MusicController().attachToCommandCenter()
                let vc = MusicPlayerViewController(songURL: song.getURL()!)
                appDelegate.playerVC = vc
                vc.modalPresentationStyle = .popover
            }

            self.present(appDelegate.playerVC!, animated: true, completion: nil)
            appDelegate.isShuffled = true
        }
        
    }
        
    
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
