//
//  MetadataViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/22/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import ID3TagEditor
import AVKit
import CoreData

class MetadataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var metadataTable: UITableView!
    
    @IBOutlet weak var albumArt: UIImageView!
    var songURL: URL?
    let mainContext = AppDelegate.viewContext
    
    let metadataFields = ["Title", "Artist", "Album Artist", "Album", "Realease Year"]
    
    var songTitle = String()
    var artist = String()
    var albumArtist = String()
    var album = String()
    var releaseYear = String()
    var artwork: UIImage?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metadataFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "metadata") as? metadataTableViewCell
        cell?.label.text = metadataFields[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell?.textfield.text = songTitle
        case 1:
            cell?.textfield.text = artist
        case 2:
            cell?.textfield.text = albumArtist
        case 3:
            cell?.textfield.text = album
        case 4:
            cell?.textfield.text = releaseYear
        default:
            break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
            let tagEditior = ID3TagEditor()
            do {
                let tag = try tagEditior.read(from: (songURL?.path)!)
                if tag?.artist != nil {artist = (tag?.artist)!} else{artist = ""}
                if tag?.title != nil {songTitle = (tag?.title)!} else{songTitle = ""}
                if tag?.albumArtist != nil {albumArtist = (tag?.albumArtist)!} else{albumArtist = ""}
                if tag?.album != nil {album = (tag?.album)!} else{album = ""}
                //apparently year has been removed
                //if tag?.year != nil {releaseYear = (tag?.year)!} else{releaseYear = ""}
                if tag?.attachedPictures != nil {
                    print("No attatched pictures")
                } else{print("Attatched pictures: ", tag?.attachedPictures?.count)}
                //if tag?.attachedPictures != nil {artwork = UIImage(data: (tag?.attachedPictures![0].art)!)} else{}
                //AttachedPicture(art: <#T##Data#>, type: <#T##ID3PictureType#>, format: <#T##ID3PictureFormat#>)
            }
            catch {
                print(error)
            }
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        artwork = getImage(songURL: songURL!)
        albumArt.image = artwork
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveMetadata(_ sender: Any) {
        var newMetadata = [String]()
        
        let cells = self.metadataTable.visibleCells as! Array<metadataTableViewCell>
        
        for cell in cells {
            newMetadata.append(cell.textfield.text!)
            print("Test: ", cell.textfield.text!)
        }
    
        do {
            let id3TagEditor = ID3TagEditor()
            let tag = ID3Tag(version: .version3,
                             artist: newMetadata[1],
                             albumArtist: newMetadata[2],
                             album: newMetadata[3],
                             title: newMetadata[0],
                             recordingDateTime: RecordingDateTime(date: RecordingDate(day: 0, month: 0, year: Int(newMetadata[4])), time: RecordingTime(hour: 0, minute: 0)),
                             genre: Genre(genre: ID3Genre.Other, description: "Other"),
                             attachedPictures: [AttachedPicture(picture: artwork!.pngData()!, type: .Other, format: .Png)],
                             trackPosition: TrackPositionInSet(position: 1, totalTracks: 1))
        
         //try ID3TagEditor.write(ID3TagEditor())
         print("Path: ", (songURL?.path)!)
            try id3TagEditor.write(tag: tag, to: (songURL?.path)!)
                
            if let song = CoreDataUtils.fetchEntity(entity: Song.self, key: "urlPath", value: songURL!.absoluteString, context: mainContext) {
                
                song.title = newMetadata[0]
                // TODO: See if you can avoid this is the metadata does not change also it might be possible for a song to have no artist and/or album, so I should consider this in the future
                let oldArtist = song.songArtist
                let oldAlbum = song.songAlbum
                
                // 1. If new artist exists set song.songArtist to new artist
                // 2. else make a new Artist and assign it to song.songArtist
                // 3. Check to see if old artist is empty with CoreDataUtils.entityIsEmpty()
                // 4. If empty delete old artist
                // 5. Repeat above steps for Album as well
                
                if let newArtist = CoreDataUtils.fetchEntity(entity: Artist.self, key: "title", value: newMetadata[1], context: mainContext) {
                    // New Artist already exists
                    song.songArtist = newArtist
                }
                else {
                    let newArtist = Artist(context: mainContext)
                    newArtist.title = newMetadata[1]
                    song.songArtist = newArtist
                }
                
                if let newAlbum = CoreDataUtils.fetchEntity(entity: Album.self, key: "title", value: newMetadata[3], context: mainContext) {
                    // New Album already exists
                    song.songAlbum = newAlbum
                }
                else {
                    let newAlbum = Album(context: mainContext)
                    newAlbum.title = newMetadata[3]
                    song.songAlbum = newAlbum
                }
                
                CoreDataUtils.deleteIfEmpty(entity: Artist.self, key: "title", value: oldArtist!.title!, context: mainContext)
                CoreDataUtils.deleteIfEmpty(entity: Album.self, key: "title", value: oldAlbum!.title!, context: mainContext)
                
                try? mainContext.save()
                
            }
         } catch {print("Error editing tag: ", error)}
    }
    
    func fetchSong(url: URL) -> Song? {
        let fetchRequest = NSFetchRequest<Song>(entityName: "Song")
        let predicate = NSPredicate(format: "urlPath = %@", url.absoluteString)
        fetchRequest.predicate = predicate
        let result = try? mainContext.fetch(fetchRequest)
        
        guard let songs = result, songs.count == 1 else {
            return nil
        }
        return songs.first
    }
    
    
    func getImage(songURL: URL) -> UIImage {
        var theImage: UIImage = #imageLiteral(resourceName: "album-cover-placeholder-light")
        
        
        
        let item = AVPlayerItem(url: songURL)
        let metadata = item.asset.metadata
        
        
        
        for theItem in metadata {
            if theItem.commonKey == nil {continue}
            if let key = theItem.commonKey, let value = theItem.value{
                if key.rawValue == "artwork"{
                    theImage = UIImage(data: value as! Data)!
                }
            }
        }
        
        
        return theImage
    }
    
    @IBAction func editImage(_ sender: Any) {
        print("Edit Pressed")
        let alert = UIAlertController(title: "Change Artwork", message: "Do you want to edit the album art?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let approve = UIAlertAction(title: "Yes", style: .default, handler: {action in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: nil)
        })
        
        alert.addAction(cancel)
        alert.addAction(approve)
        present(alert, animated: true, completion: nil)
    }
    
}

extension MetadataViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Did finish picking. Info = " + "\(info)")
        var selectedImage: UIImage?
        if let croppedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage { 
            selectedImage = croppedImage
        }
        artwork = selectedImage
        albumArt.image = selectedImage
        self.dismiss(animated: true, completion: nil)
        
        //present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
