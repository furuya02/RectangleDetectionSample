//
//  PreviewViewController.swift
//  RectangleDetectionSample
//
//  Created by hirauchi.shinichi on 2017/02/27.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var openCv = OpenCv()
    
    var orgImage:UIImage!
    var cards :[Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.8)
        
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
            
            let img = openCv.afineTransform(trimmedImage,&src)
            imageView.image = img
            break
        }
    }

    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
