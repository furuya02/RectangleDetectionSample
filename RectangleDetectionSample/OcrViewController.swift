//
//  OcrViewController.swift
//  RectangleDetectionSample
//
//  Created by hirauchi.shinichi on 2017/03/02.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit

class OcrViewController: UIViewController, UITableViewDataSource {

    var card: Card!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        imageView.image = card.image
        
        
        tableView.separatorColor = UIColor(red:0.23, green:0.23, blue:0.23, alpha:1.0)
        tableView.rowHeight = 20
    }

    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return card.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = card.lines[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
