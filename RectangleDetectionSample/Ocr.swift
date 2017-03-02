//
//  ReadText.swift
//  ReadTextInImagesSample
//
//  Created by hirauchi.shinichi on 2017/03/01.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import Foundation

class Ocr {
    
    let url = "https://api.projectoxford.ai/vision/v1.0/ocr"
    let key = "9ca5xxxxxxxxxxxxxxxxxxd445e4"
    
    func recognizeCharacters(imageData: Data, language: String, detectOrientation: Bool,completion: @escaping (_ response: [String]? ) -> Void) throws {
        
        let requestUrlString = url + "?language=" + language + "&detectOrientation=\(detectOrientation)"
        //let requestUrl = URL(string: requestUrlString)
        
        var request = URLRequest(url: URL(string: requestUrlString)!)
        request.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            if error != nil{
                print("Error -> \(error)")
                completion(nil)
                return
            }else{
                let results = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                DispatchQueue.main.async {
                    completion(self.extractStringsFromDictionary(results!))
                }
            }
        }
        task.resume()
    }
    
    // レスポンスのJSONから、文字列を行単位で抽出する
    fileprivate func extractStringsFromDictionary(_ dictionary: [String : AnyObject]) -> [String] {
        var result: [String] = []
        let regions = dictionary["regions"] as? [[String:AnyObject]]
        for region in regions! {
            let lines = region["lines"] as! NSArray
            let inLine = lines.map {($0 as? NSDictionary)?["words"] as! [[String : AnyObject]] }
            inLine.map { $0.map { $0["text"] as! String }.reduce("", +) }.forEach { result.append($0) }
            result.append("")
        }
        return result
    }
}
