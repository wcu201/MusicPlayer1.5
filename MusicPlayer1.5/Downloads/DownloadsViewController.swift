//
//  DownloadsViewController.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/20/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var downloadTable: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0{
            if UserDefaults.standard.array(forKey: "downloadHistory") != nil {
                return (UserDefaults.standard.array(forKey: "downloadHistory")?.count)!
            }
        }
        
        if section==1{return appDelegate.downloadProgressQueue.count}
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadCell") as? downloadTableViewCell
        
        if indexPath.section==0{
            cell?.progressBar.isHidden = true
            cell?.progressNumber.isHidden = true
            cell?.urlLabel.text = UserDefaults.standard.array(forKey: "downloadHistory")?[indexPath.row] as? String
        }
        if indexPath.section==1{
            cell?.urlLabel.isHidden = true
            let urlKeys = Array(appDelegate.downloadProgressQueue.keys)
            while appDelegate.downloadProgressQueue[urlKeys[indexPath.row]]!<Float(1.0) {
                let progress = appDelegate.downloadProgressQueue[urlKeys[indexPath.row]]!
                cell?.progressBar.progress = progress
                
                if progress<Float(0.1){cell?.progressNumber.text = " \(Int(progress*100))%"}
                else{cell?.progressNumber.text = "\(Int(progress*100))%"}
            }
        }

        return cell!
        //return tableView.dequeueReusableCell(withIdentifier: "")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadTable.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
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
