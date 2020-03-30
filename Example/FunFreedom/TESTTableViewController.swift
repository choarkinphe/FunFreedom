//
//  TESTTableViewController.swift
//  FunFreedom_Example
//
//  Created by 肖华 on 2020/3/23.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import FunFreedom

extension UIColor {
    
    static var random: UIColor {
        return UIColor.init(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
    }
    
    func alpha(_ alpha: CGFloat) -> Self {
        
        withAlphaComponent(alpha)
        
        return self
    }
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat? = nil) {
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a ?? 1)

    }
    
}

extension UITableView {
    func dequeueCell<T>(_ type: T.Type, reuseIdentifier: String) -> T where T: UITableViewCell {
        
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier) else {
            
            return T.init(style: .default, reuseIdentifier: reuseIdentifier)
            
        }
        
        return cell as! T
    }
    
    func dequeueHeaderFooterView<T>(_ type: T.Type, reuseIdentifier: String) -> T where T: UITableViewHeaderFooterView {
        
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) else {
            
            return T.init(reuseIdentifier: reuseIdentifier)
            
        }
        
        return headerFooterView as! T
    }
}
class TESTTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    private var downloadList = [String]()
    private var waitList = [String]()
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let downloadTasks = FunFreedom.DownloadManager.default.downloadTasks,
           let waitTasks = FunFreedom.DownloadManager.default.waitTasks
        {
            downloadList = Array(downloadTasks.keys)
            waitList = Array(waitTasks.keys)
        }
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return downloadList.count
        }
        return waitList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(DownloadCell.self, reuseIdentifier: "download_cell")
        
//        cell.textLabel?.text =
//        cell.backgroundColor = UIColor.random
        // Configure the cell...
        if indexPath.section == 0 {
            if let responder = FunFreedom.DownloadManager.default.downloadTasks?[downloadList[indexPath.row]] {
            
                if let fileName = responder.fileName {
                    cell.textLabel?.text = fileName
                    
                    responder.progress { (progress) in
                        cell.textLabel?.text = String(format: "%@: %.2f%%", fileName, progress.fractionCompleted * 100)
                    }
                }
//                    .progressHandler({ (progress) in
//
//                })
            }
        } else {
//            if let responder = FunFreedom.DownloadManager.default.downloadTasks?[waitList[indexPath.row]] {
//            
//            }
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    class DownloadCell: UITableViewCell {
        
    }
}

