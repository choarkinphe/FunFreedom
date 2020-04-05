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
    private var list = [[String]]()
//    private var waitList = [String]()
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let downloadTasks = FunFreedom.DownloadManager.default.downloadTasks,
           let waitTasks = FunFreedom.DownloadManager.default.waitTasks,
           let finishTasks = FunFreedom.DownloadManager.default.finishedTasks
        {
            list = [Array(downloadTasks.keys)]
//            list = [Array(downloadTasks.keys)]
//            waitList = Array(waitTasks.keys)
            list.append(Array(waitTasks.keys))
            list.append(Array(finishTasks.keys))
        }
        
        return list.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return list[section].count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueHeaderFooterView(UITableViewHeaderFooterView.self, reuseIdentifier: "Header")
        switch section {
        case 0:
            header.textLabel?.text = "下载中"
            case 1:
            header.textLabel?.text = "等待中"
            case 2:
            header.textLabel?.text = "已完成"
        default:
            break
        }
        
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(DownloadCell.self, reuseIdentifier: "download_cell")
        
//        cell.textLabel?.text =
//        cell.backgroundColor = UIColor.random
        // Configure the cell...
//        if indexPath.section == 0 {
        if let responder = FunFreedom.DownloadManager.default.getTask(identifier: list[indexPath.section][indexPath.row]) {
            cell.textLabel?.text = responder.fileName ?? "等待中..."
                    
                    responder.progress { (progress) in
                        if let fileName = responder.fileName {
                            cell.textLabel?.text = fileName
                        cell.textLabel?.text = String(format: "%@: %.2f%%", fileName, progress.fractionCompleted * 100)
                    }
                }
//                    .progressHandler({ (progress) in
//
//                })
            
//            responder.complete { (url, error) in
//                self.tableView.reloadData()
//            }
            
            responder.stateChanged { (state) in
                self.tableView.reloadData()
            }
            }
//        } else {
//            if let responder = FunFreedom.DownloadManager.default.downloadTasks?[waitList[indexPath.row]] {
//
//            }
//        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let responder = FunFreedom.DownloadManager.default.getTask(identifier: list[indexPath.section][indexPath.row]) {
            if responder.state == .wait || responder.state == .dormancy {
            if let request = responder.request {
                
                FunFreedom.DownloadManager.default.buildResponder(request: request)?.response(nil)
            }
            } else if responder.state == .download {
                // 暂停任务
                responder.suspend()
            } else if responder.state == .finish {
                // 移除任务
                responder.remove(sameAsFile: true)
            }
            
            
        }
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

