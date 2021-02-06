//
//  DownloadsViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/20/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import CoreData

class DownloadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var downloadTable: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // Map songIDs to table view rows
    var downloadsTableMap = [ String : Int ]()
    
    var fetchedResultsController: NSFetchedResultsController<Song> {
        let context = AppDelegate.viewContext
        let resultsController = CoreDataUtils.fetchSongs(context: context, onlyCompletedDownloads: false)
        
        return resultsController!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let objects = fetchedResultsController.fetchedObjects {
            return objects.count
        }
        return 0
//        if section == 0  {
//            if UserDefaults.standard.array(forKey: "downloadHistory") != nil {
//                return (UserDefaults.standard.array(forKey: "downloadHistory")?.count)!
//            }
//        }
//
//        if section == 1 { return appDelegate.downloadProgressQueue.count }
//
//        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadsCell") as? DownloadsTableViewCell
        
        let song = fetchedResultsController.object(at: indexPath)
        if let songID = song.songID {
            downloadsTableMap[songID.uuidString] = indexPath.row
        }
        
        cell?.songPath.text = song.urlPath
//        if indexPath.section == 0 {
//            cell?.progressBar.isHidden = true
//            cell?.progressNumber.isHidden = true
//            cell?.urlLabel.text = UserDefaults.standard.array(forKey: "downloadHistory")?[indexPath.row] as? String
//        }
//        if indexPath.section == 1 {
//            cell?.urlLabel.isHidden = true
//            let urlKeys = Array(appDelegate.downloadProgressQueue.keys)
//            while appDelegate.downloadProgressQueue[urlKeys[indexPath.row]]!<Float(1.0) {
//                let progress = appDelegate.downloadProgressQueue[urlKeys[indexPath.row]]!
//                cell?.progressBar.progress = progress
//
//                if progress<Float(0.1){cell?.progressNumber.text = " \(Int(progress*100))%"}
//                else{cell?.progressNumber.text = "\(Int(progress*100))%"}
//            }
//        }

        return cell ?? UITableViewCell()
        //return tableView.dequeueReusableCell(withIdentifier: "")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadTable.register(DownloadsTableViewCell.self, forCellReuseIdentifier: "downloadsCell")
        downloadTable.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgressBar(_:)), name: .downloadProgressUpdated, object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateProgressBar(_ notification: Notification){
        let notif = notification
        print(notif)
        
    }
    

}
