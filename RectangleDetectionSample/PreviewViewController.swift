//
//  PreviewViewController.swift
//  RectangleDetectionSample
//
//  Created by hirauchi.shinichi on 2017/02/27.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var openCv = OpenCv()
    
    var orgImage: UIImage!
    var cards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.8)
        
        tableView.dataSource = self
        tableView.delegate = self

        let ocr = Ocr()
        
        for card in cards {
            // イメージの一部の切り取り
            let srcImageRef = orgImage?.cgImage
            let imageRef = srcImageRef?.cropping(to: card.orgRect)
            let trimmedImage = UIImage(cgImage: imageRef!)
            
            var src: [CGPoint] = []
            src.append(CGPoint(x: card.points[0].x - card.orgRect.origin.x, y: card.points[0].y - card.orgRect.origin.y))
            src.append(CGPoint(x: card.points[2].x - card.orgRect.origin.x, y: card.points[2].y - card.orgRect.origin.y))
            src.append(CGPoint(x: card.points[3].x - card.orgRect.origin.x, y: card.points[3].y - card.orgRect.origin.y))
            src.append(CGPoint(x: card.points[1].x - card.orgRect.origin.x, y: card.points[1].y - card.orgRect.origin.y))
            
            if let image = openCv.afineTransform(trimmedImage,&src) {
                 card.image = image
                 //UIImageWriteToSavedPhotosAlbum(image, self, nil, nil) カメラロール保存（デバッグ用）
                try! ocr.recognizeCharacters(imageData: UIImagePNGRepresentation(image)!, language: "unk", detectOrientation: true, completion: { (response) in
                    card.lines = response!
                    print(card.lines)
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ocrViewController = segue.destination as? OcrViewController, let indexPath = sender as? IndexPath {
            ocrViewController.card = cards[indexPath.row]
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         performSegue(withIdentifier: "gotoOcrView", sender: indexPath)
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let card = cards[indexPath.row]
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = card.image
        if card.lines.count > 0 {
            imageView.layer.borderColor = UIColor.blue.cgColor
            imageView.layer.borderWidth = 3
        }
        return cell
    }
    

    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
