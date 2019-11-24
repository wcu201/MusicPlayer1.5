//
//  PlaylistViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/23/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistSongCell") as? songTableViewCell
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPlaylist(songs: [URL], playlistName: String) {
        if UserDefaults.standard.array(forKey: "playlist_\(playlistName)") != nil{
            print("error")
        }
        else {
            UserDefaults.standard.set(playlistName, forKey: "userPlaylists")
            UserDefaults.standard.set(songs, forKey: "playlist_\(playlistName)")}
    }
    
    @IBAction func addPlaylist(_ sender: Any) {
        
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
