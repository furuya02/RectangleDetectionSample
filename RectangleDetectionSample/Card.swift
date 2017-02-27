//
//  Card.swift
//  RectangleDetectionSample
//
//  Created by hirauchi.shinichi on 2017/02/26.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import Foundation


class Card: NSObject {
    
    var rect: CGRect! // 概説の矩形
    var points: [CGPoint]! // 四隅の位置

    //      points[0]    points[1]
    //         +-------------+
    //         |             |
    //         |             |
    //         +-------------+
    //      points[2]    points[3]
    
    
    init(p1: CGPoint, p2: CGPoint, p3: CGPoint, p4: CGPoint){
        //points = [p1, p2, p3, p4].sorted { $0.x < $1.x }
        let arr = [p1, p2, p3, p4]
        
        let y = min(arr[0].y, arr[1].y, arr[2].y, arr[3].y)
        let x = min(arr[0].x, arr[1].x, arr[2].x, arr[3].x)
        
        let height = max(arr[0].y, arr[1].y, arr[2].y, arr[3].y) - y
        let width = max(arr[0].x, arr[1].x, arr[2].x, arr[3].x) - x
        rect = CGRect(x: x, y: y, width: width, height: height)
        
        points = []
        let uppers = arr.sorted(by: {$0.y < $1.y}) // 上辺の2点が先頭の２要素
        let unders = arr.sorted(by: {$0.y > $1.y}) // 下辺の2点が先頭の２要素
        // 先頭の２要素を取り出して、xでソートする（左側を先に取り出す）
        points.append(contentsOf: uppers.enumerated().filter({$0.offset < 2}).map{ $0.element }.sorted(by: {$0.x < $1.x}))
        points.append(contentsOf: unders.enumerated().filter({$0.offset < 2}).map{ $0.element }.sorted(by: {$0.x < $1.x}))
    }
}
