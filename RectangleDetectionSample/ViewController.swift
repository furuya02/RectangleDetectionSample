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
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avCapture.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    func capture(image: UIImage) {
        let img = openCv.searchLine(image)
        if sw && openCv.rect != CGRect.zero {
            
            print("OpenCV.Rect=(openCv.rect)")

            let imageW = img?.size.width;
            let imageH = img?.size.height;
            
            //CGImageRef
            print(openCv.rect)
            let srcImageRef = img?.cgImage
            var imageRef = srcImageRef?.cropping(to: openCv.rect)
            let trimmedImage = UIImage(cgImage: imageRef!)
            imageView.image = trimmedImage
            
            
        } else {
            imageView.image = img! as UIImage;
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

