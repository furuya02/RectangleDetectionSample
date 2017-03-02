//
//  ViewController.swift
//  RectangleDetectionSample
//
//  Created by hirauchi.shinichi on 2017/02/20.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AVCaptureDelegate {

    var openCv = OpenCv()
    var avCapture = AVCapture()
    
    var cards :[Card] = []
    var guideViews:[UIView] = []
    
    var isPreviewing = false
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for n in 0 ..< 4 {
            let view = UIView()
            view.layer.borderColor = UIColor.cyan.cgColor
            view.layer.borderWidth = 3
            view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
            view.isHidden = true
            imageView.addSubview(view)
            guideViews.append(view)
        }
        
        avCapture.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    // [Card]の初期化
    func reinitializeCard(raito: CGFloat) {
        cards = []
        for rect in openCv.rects {
            let points = rect as! NSArray
            let card = Card(p1: points[0] as! CGPoint ,p2: points[1] as! CGPoint, p3: points[2] as! CGPoint, p4: points[3] as! CGPoint, raito: raito)
            cards.insert(card, at: 0)
        }
        //print("cards.count = \(cards.count)")
    }

    func capture(image: UIImage) {
        let img = openCv.searchLine(image)
        imageView.image = img! as UIImage;

        
        // 縦横比から、縦横のどちらが基準になっているかを確認する
        //print("image width=\(imageView.image?.size.width) height=\(imageView.image?.size.height)")
        let ratioImage = (imageView.image?.size.height)! / (imageView.image?.size.width)!
        //print("imageView.width=\(imageView.bounds.size.width) height=\(imageView.bounds.size.height)")
        let viewRaito = (imageView.bounds.size.height) / (imageView.bounds.size.width)
        
        
        
        var isHorizontalReference = true // 横基準
        if ratioImage < viewRaito { // 縦基準の場合
            isHorizontalReference = false
        }
        var offsetX:CGFloat = 0, offsetY:CGFloat = 0
        var raito = imageView.bounds.width / (imageView.image?.size.width)!
        if !isHorizontalReference {
            raito = imageView.bounds.height / (imageView.image?.size.height)!
            offsetX = ((imageView.image?.size.width)!  * raito - imageView.bounds.width) / 2
        } else {
            offsetY = ((imageView.image?.size.height)! * raito - imageView.bounds.height) / 2
        }
        
        reinitializeCard(raito: raito)
        
        if cards.count > 0 && !isPreviewing {

            // ガイドビュー
            for guideView in guideViews {
                guideView.isHidden = true
            }
            for (i,card) in cards.enumerated() {
                guideViews[i].isHidden = false
                let r = card.scaleRect
                guideViews[i].frame = CGRect(x: (r?.origin.x)! - offsetX, y: (r?.origin.y)! - offsetY , width: (r?.size.width)!, height: (r?.size.height)!)
                //print("y=\((r?.origin.y)!) OffsetY=\(offsetY)")
            }
        } else {
            for guideView in guideViews {
                guideView.isHidden = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let previewViewController: PreviewViewController = segue.destination as! PreviewViewController{
            previewViewController.orgImage = imageView.image
            previewViewController.cards = cards
        }
    }
    
    @IBAction func tapButton(_ sender: Any) {
    }

    @IBAction func returnPreview(segue: UIStoryboardSegue) {
        isPreviewing = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPreviewing = true
        performSegue(withIdentifier: "gotoPreviewView", sender: nil)
    }

}

