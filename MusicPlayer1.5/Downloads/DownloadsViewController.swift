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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaults.standard.array(forKey: "downloadHistory") != nil {
        return (UserDefaults.standard.array(forKey: "downloadHistory")?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadCell") as? downloadTableViewCell
        cell?.urlLabel.text = UserDefaults.standard.array(forKey: "downloadHistory")?[indexPath.row] as? String
        return cell!
        //return tableView.dequeueReusableCell(withIdentifier: "")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadTable.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
