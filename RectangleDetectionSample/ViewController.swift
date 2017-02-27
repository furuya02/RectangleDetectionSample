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
    func reinitializeCard() {
        cards = []
        for rect in openCv.rects {
            let points = rect as! NSArray
            let card = Card(p1: points[0] as! CGPoint ,p2: points[1] as! CGPoint, p3: points[2] as! CGPoint, p4: points[3] as! CGPoint)
            cards.append(card)
        }
        print("cards.count = \(cards.count)")
    }

    func capture(image: UIImage) {
        let img = openCv.searchLine(image)
        imageView.image = img! as UIImage;

        reinitializeCard()
        if cards.count > 0 {
            // 縮小イメージ
//            let srcImageRef = img?.cgImage
//            var imageRef = srcImageRef?.cropping(to: cards[0].rect)
//            let trimmedImage = UIImage(cgImage: imageRef!)
//            imageView.image = trimmedImage
            
            let offsetX = (imageView.image?.size.width)! - imageView.bounds.width
            let offsetY = (imageView.image?.size.height)! - imageView.bounds.height
            print("X=\(offsetX) Y=\(offsetY)")
            print("\(cards[0].points[0].x),\(cards[0].points[0].y) - \(cards[0].points[3].x),\(cards[0].points[3].y)")

            // ガイドビュー
            for guideView in guideViews {
                guideView.isHidden = true
            }
            for (i,card) in cards.enumerated() {
                guideViews[i].isHidden = false
                
                let r = card.rect
                guideViews[i].frame = CGRect(x: (r?.origin.x)! - offsetX/2, y: (r?.origin.y)! - offsetY/2, width: (r?.size.width)!, height: (r?.size.height)!)
            }
        } else {
            for guideView in guideViews {
                guideView.isHidden = true
            }
        }
    }
    
    var sw = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sw = true

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sw = false
    }

    @IBAction func tapShutterButton(_ sender: Any) {
        
//        isChecking = true
//        let alert: UIAlertController = UIAlertController(title: "撮影完了", message: "保存しますか？", preferredStyle:  UIAlertControllerStyle.alert)
//        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
//            (action: UIAlertAction!) -> Void in
//            //let resize = self.resizeImage(image: self.imageView.image!, width: Int(UIScreen.main.bounds.width), height: Int(UIScreen.main.bounds.height) * 2)
//            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
//            self.isChecking = false
//        })
//        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
//            (action: UIAlertAction!) -> Void in
//            self.isChecking = false
//        }))
//        alert.addAction(defaultAction)
//        present(alert, animated: true, completion: nil)
    }
    


}

