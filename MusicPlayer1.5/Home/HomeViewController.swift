//
//  HomeViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 3/30/19.
//  Copyright © 2019 William  Uchegbu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection: UICollectionView!
    
    
    let sections = ["Songs", "Artists", "Albums", "Playlists", "Recently Added"]
    let sectionImages = [#imageLiteral(resourceName: "outline_library_music_black_36dp"),#imageLiteral(resourceName: "baseline_recent_actors_black_48dp"),#imageLiteral(resourceName: "baseline_album_black_36dp"),#imageLiteral(resourceName: "outline_playlist_play_black_36dp"),#imageLiteral(resourceName: "baseline_access_time_black_36dp")]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        cell.layer.cornerRadius = 15
        
        let img = resizeImage(image: sectionImages[indexPath.row], targetSize: CGSize(width: 20, height: 20))
        cell.icon.image = img
        cell.icon.image = img.withRenderingMode(.alwaysTemplate)
        cell.icon.tintColor = UIColor.white
        cell.label.text = sections[indexPath.row]
        cell.backgroundColor = UIColor(red: 41/255, green: 45/255, blue: 51/255, alpha: 1.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "goToSongs", sender: self)
        default:
            break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
