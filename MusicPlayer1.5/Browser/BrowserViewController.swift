//
//  BrowserViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/19/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SVProgressHUD

class BrowserViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UISearchBarDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var addressBar: UISearchBar?
    var backButton: UIBarButtonItem?
    var forwardButton: UIBarButtonItem?
    var processingValidation = false
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print("Launch my Native Camera")
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("Navigation Type: ", navigationAction.navigationType)
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            let req = navigationAction.request
            print(req)
            decisionHandler(WKNavigationActionPolicy.allow)
            if !processingValidation {
                processingValidation = true
                Alamofire.request(req.url!).validate(contentType: ["audio/mpeg", "application/octet-stream"]).response { response in
                    // If the content type is audio
                    if response.error == nil {
                        self.createActionSheet(title: "Download", message: "Do you want to download this mp3?", songURL: req.url!)
                    }
                    self.processingValidation = false
                }
            }
            
            addressBar?.text = req.url?.absoluteString
            return
        }
        print("no link")
        decisionHandler(WKNavigationActionPolicy.allow)
        let req = navigationAction.request
        addressBar?.text = req.url?.absoluteString
        print(req)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SVProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
    //func web
    
    @IBOutlet weak var browser: WKWebView!
    var fileLocalURLArr = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        //browser.configuration.userContentController.add(self, name: "observe")
        
        let contentController = WKUserContentController();
        contentController.add(self, name: "callbackHandler")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAddressBar()
        browser.uiDelegate = self
        browser.navigationDelegate = self

        let myURL = URL(string: "https://www.google.com")
        let myRequest = URLRequest(url: myURL!)
        browser.load(myRequest)
        
        SVProgressHUD.setBackgroundColor(.clear)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        browser.goBack()
    }
    
    @IBAction func goForward(_ sender: Any) {
        browser.goForward()
    }
    
    
    //downloadURL(url: URL(string: "https://a.tumblr.com/tumblr_lz99inw5kp1r9sexqo1.mp3")!)
    
    func downloadURL(url: URL) {
        //Create Song NSManagedObject
        let addedSong = CoreDataUtils.addSongToCoreData(context: AppDelegate.viewContext)
        guard let song = addedSong.0 else {
            if let error = addedSong.1 { print(error) }
            return
        }
    
        
        //Creates destination where file is stored
        let dest: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL:NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            print("***documentURL: ",documentsURL)
            var fileURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            if url.pathExtension.isEmpty {
                fileURL?.appendPathExtension("mp3")
            }
            print("***fileURL: ",fileURL ?? "")
            return (fileURL!,[.removePreviousFile, .createIntermediateDirectories])
        }
        
        //Adding number of downloads icon (shows how many things are being downloaded)
        if (self.navigationController?.tabBarController?.tabBar.items![2].badgeValue == nil) {
            self.navigationController?.tabBarController?.tabBar.items![2].badgeValue = "1"
        }
        else {
            let numberOfCurrentDownloads = Int(self.navigationController?.tabBarController?.tabBar.items![2].badgeValue ?? "0")
            self.navigationController?.tabBarController?.tabBar.items![2].badgeValue = "\(numberOfCurrentDownloads!+1)"
        }
        
        //Adding record to download history
        //TODO: Remove this. Shouldn't be storing download history in User Defaults Settings
        if (UserDefaults.standard.array(forKey: "downloadHistory")) == nil {
            UserDefaults.standard.set([url.lastPathComponent], forKey: "downloadHistory")
        }
        else {
            var downloads = UserDefaults.standard.array(forKey: "downloadHistory")
            downloads?.append(url.lastPathComponent)
            UserDefaults.standard.set(downloads, forKey: "downloadHistory")
        }
        

        //Performing actual download operation
        Alamofire.download(url, to: dest)
            .downloadProgress(closure: {(progress) in
                print("Progress: \(progress.fractionCompleted)")
                song.updateDownloadProgress(fractionCompleted: progress.fractionCompleted)
                //self.appDelegate.downloadProgressQueue[url] = Float(progress.fractionCompleted)
            }).response(completionHandler: {(complete) in
                //let header = ["Content-Disposition": "audio.mp3"]
                self.navigationController?.tabBarController?.tabBar.items![2].badgeValue = nil
                if complete.error == nil, let filePath = complete.destinationURL?.path {
                    print ("Download Finished: ", filePath)
                    print ("url: ", url.lastPathComponent)
                    self.appDelegate.downloadProgressQueue.removeValue(forKey: url)
                    self.fileLocalURLArr.append(url.lastPathComponent)
                    
                    if let destinationURL = complete.destinationURL {
                        song.addURL(url: destinationURL)
                        song.downloadProgress = 100
                        song.downloaded = true
                        try? AppDelegate.viewContext.save()
                    }
                    //CoreDataUtils.addSongToCoreData(url: complete.destinationURL!, context: AppDelegate.viewContext)
                    //AppDelegate.populateDownloadLibrary()
                    //Encoder
                }
                else {
                    print("Unsuccessful Download")
                }
        })
    }
    
    //Create alert asking user to commit to download
    func createActionSheet(title: String, message: String, songURL: URL){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        
        // Should removed validate below since I do it earlier
        let downloadAction = UIAlertAction(title: "Download", style: .default, handler: {(action) in
                Alamofire.request(songURL).validate(contentType: ["audio/mpeg", "application/octet-stream"]).response { response in
                    if songURL.pathExtension == "mp3" || (songURL.pathExtension.isEmpty && response.error == nil) {
                        self.downloadURL(url: songURL)
                    }
                    else {
                        let errorMessage = response.error != nil ? response.error?.localizedDescription : "Uknown Error"
                        let errorAlert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAddressBar() {
        
        let search = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        search.searchBarStyle = .minimal
        search.keyboardType = .URL
        search.returnKeyType = .go
        search.autocapitalizationType = UITextAutocapitalizationType.none
        search.showsCancelButton = true
        search.enablesReturnKeyAutomatically = true
        (search.value(forKey: "searchField") as? UITextField)?.textColor = .white
        
        addressBar = search
        
        let backBTN = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let forwardBTN = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        backBTN.imageView?.image = #imageLiteral(resourceName: "outline_keyboard_arrow_left_black_48pt")
        backBTN.setImage(#imageLiteral(resourceName: "outline_keyboard_arrow_left_black_48pt"), for: .normal)
        let backItem = UIBarButtonItem(customView: backBTN)
        backBTN.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        
        let backWidth = backItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        backWidth?.isActive = true
        let backHeight = backItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        backHeight?.isActive = true
        
        forwardBTN.imageView?.image = #imageLiteral(resourceName: "baseline_keyboard_arrow_right_black_18pt_3x")
        forwardBTN.setImage(#imageLiteral(resourceName: "baseline_keyboard_arrow_right_black_18pt_3x"), for: .normal)
        let forwardItem = UIBarButtonItem(customView: forwardBTN)
        forwardBTN.addTarget(self, action: #selector(goForward(_:)), for: .touchUpInside)
        
        let forwardWidth = forwardItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        forwardWidth?.isActive = true
        let forwardHeight = forwardItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        forwardHeight?.isActive = true
        
        backButton = backItem
        forwardButton = forwardItem
        
        self.navigationItem.titleView = addressBar
        self.navigationItem.leftBarButtonItems = [backButton!, forwardButton!]
        
        addressBar?.delegate = self
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        browser.load(URLRequest(url: URL(string: searchBar.text!)!))
    }

}
