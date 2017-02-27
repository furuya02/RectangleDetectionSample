//
//  OpenCv.m
//  RectangleDetectionSample
//
//  Created by hirauchi.shinichi on 2017/02/20.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RectangleDetectionSample-Bridging-Header.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

//using namespace cv;


@implementation OpenCv : NSObject

// 台形判定（使用しない）
-(bool)DetectionTrapezoid:(NSArray *) points {
    
    // X座標でソート
    NSArray *array = [points sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGPoint p1, p2;
        [obj1 getValue:&p1];
        [obj2 getValue:&p2];
        if ( p1.x < p2.x ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( p1.x > p2.x ) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    for (NSValue* value in array) {
        CGPoint pt;
        [value getValue:&pt];
        NSLog(@"x=%d y=%d", int(pt.x), int(pt.y));
    }
    
    CGPoint point1 = [[points objectAtIndex:0] CGPointValue];
    CGPoint point2 = [[points objectAtIndex:1] CGPointValue];
    CGPoint point3 = [[points objectAtIndex:2] CGPointValue];
    CGPoint point4 = [[points objectAtIndex:3] CGPointValue];
    
    //①が下の場合は、④は、必ず下になる
    if (point1.y > point2.y && point3.y < point4.y){
        return true;
    }
    //①が上の場合は、④は、必ず上になる
    if (point1.y < point2.y && point3.y > point4.y){
        return true;
    }
    return false;
}


// 概説矩形の取得
-(CGRect)getRect:(std::vector<cv::Point>) contour {
    NSMutableArray *points = [NSMutableArray new];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(contour[0].x, contour[0].y)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(contour[1].x, contour[1].y)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(contour[2].x, contour[2].y)]];
    [points addObject:[NSValue valueWithCGPoint:CGPointMake(contour[3].x, contour[3].y)]];
    
    // X座標でソート
    NSArray *array = [points sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGPoint p1, p2;
        [obj1 getValue:&p1];
        [obj2 getValue:&p2];
        if ( p1.x < p2.x ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( p1.x > p2.x ) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];

    CGPoint point1 = [[array objectAtIndex:0] CGPointValue];
    CGPoint point2 = [[array objectAtIndex:1] CGPointValue];
    CGPoint point3 = [[array objectAtIndex:2] CGPointValue];
    CGPoint point4 = [[array objectAtIndex:3] CGPointValue];
    
    int x = point1.x;
    // 最大横幅
    int width = MAX(point4.x - point1.x, point3.x - point2.x);
    // 最大縦幅
    int height,y;
    if (point1.y > point2.y){ //①が下の場合
        y = MIN(point2.y, point3.y);
        height = MAX(point1.y, point4.y) - y;
    } else { // ①が上の場合
        y = MIN(point1.y,point4.y);
        height = MAX(point2.y, point3.y) - y;
    }
    return CGRectMake(x, y, width, height);
}

std::vector<std::vector<cv::Point> > contours;

- (NSArray *)getRects
{
    NSMutableArray *rects = [NSMutableArray new];
    for( int i = 0; i< contours.size(); i++ ) {
        NSMutableArray *points = [NSMutableArray new];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(contours[i][0].x, contours[i][0].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(contours[i][1].x, contours[i][1].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(contours[i][2].x, contours[i][2].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(contours[i][3].x, contours[i][3].y)]];

        [rects addObject:points];
    }
    return rects;
}

-(UIImage *)SearchLine:(UIImage *)image {
    
    // 方向を修正
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    cv::Mat gray; // 矩形検出用

    // 2値化
    cv::cvtColor(mat,gray,CV_BGR2GRAY);
    //家の机だとこれでOKだった
    cv::threshold(gray,gray, 0, 255, cv::THRESH_BINARY|cv::THRESH_OTSU);
    // 職場がどこちら（200のところは、180以上ぐらいでOKだった）
//    cv::threshold(gray, gray, 200, 255, CV_THRESH_TOZERO_INV );
//    cv::bitwise_not(gray, gray);
//    cv::threshold(gray, gray, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    
    // 2値画像，輪郭（出力），階層構造（出力），輪郭抽出モード，輪郭の近似手法
    std::vector<std::vector<cv::Point> > tmpContours;
    std::vector<cv::Vec4i> hierarchy;
    //findContoursをかけるとデータが壊れるので、テンポラリで作業する
    cv::Mat tmpGray = gray.clone(); // 輪郭検出用
    // 下のほうが取れている感じ
    //cv::findContours(tmpGray, contours, hierarchy, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_TC89_KCOS);
    cv::findContours(tmpGray, tmpContours, hierarchy, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_TC89_L1);
    //    輪郭抽出モード
    //    RETR_EXTERNAL 最も外側の輪郭のみを抽出します．すべての輪郭に対して hierarchy[i][2]=hierarchy[i][3]=-1 がセットされます
    //    RETR_LIST すべての輪郭を抽出しますが，一切の階層構造を保持しません
    //    RETR_CCOMP 全ての輪郭を抽出し，それらを2階層構造として保存します：上のレベルには，連結成分の外側の境界線が，下のレベルには，連結成分の内側に存在する穴の境界線が属します．ある連結成分の穴の内側に別の輪郭が存在する場合，その穴は上のレベルに属します
    //    RETR_TREE 全ての輪郭を抽出し，入れ子構造になった輪郭を完全に表現する階層構造を構成します．この完全な階層構造は，OpenCVの contours.c デモで見ることができます
    //    輪郭の近似手法：
    //    CV_CHAIN_APPROX_NONE すべての輪郭点を完全に格納します．つまり，この手法により格納された任意の隣り合う2点は，互いに8近傍に存在します
    //    CV_CHAIN_APPROX_SIMPLE 水平・垂直・斜めの線分を圧縮し，それらの端点のみを残します．例えば，まっすぐな矩形の輪郭線は，4つの点にエンコードされます
    //    CV_CHAIN_APPROX_TC89_L1,CV_CHAIN_APPROX_TC89_KCOS Teh-Chinチェーン近似アルゴリズムの1つを適用します． TehChin89 を参照してください
    
    contours.clear();
    for( int i = 0; i< tmpContours.size(); i++ ) // iterate through each contour.
    {
        // ある程度の面積が有るものだけに絞る
        double a = contourArea( tmpContours[i],false);  //  Find the area of contour
        if( a > 15000) {
            //輪郭を直線近似する
            std::vector< cv::Point > approx;
            cv::approxPolyDP(cv::Mat(tmpContours[i]), approx, 0.01 * cv::arcLength(tmpContours[i], true), true);
            // 矩形のみ取得
            if (approx.size() == 4) {
                contours.push_back(approx);
            }
        }
    }
//    std::cout << "■num of contours = " << contours.size() << std::endl;
    
    /// 輪郭の描画  画像，輪郭，描画輪郭指定インデックス，色，太さ，種類，階層構造，描画輪郭の最大レベル
    int max_level = 0;
    for(int i = 0; i < contours.size() ; i++){
        // 白黒では見えないので、matだけ
        //cv::drawContours(mat, contours, i, cv::Scalar(255, 0, 0, 255), 1, CV_AA, hierarchy, max_level);
    }
    // どちらをモニターするかで変更する
    return MatToUIImage(mat);
    //return MatToUIImage(gray);
}

-(UIImage *)AfineTransform:(UIImage *)image :(CGPoint *)src {

    cv::Mat mat;
    UIImageToMat(image, mat);
    
    cv::Point2f srcTri[4], dstTri[4];
    srcTri[0].x = src[0].x;
    srcTri[0].y = src[0].y;
    dstTri[0].x = 0;
    dstTri[0].y = 0;
    srcTri[1].x = src[1].x;
    srcTri[1].y = src[1].y;
    dstTri[1].x = 0;
    dstTri[1].y = mat.rows;
    srcTri[2].x = src[2].x;
    srcTri[2].y = src[2].y;
    dstTri[2].x = mat.cols;
    dstTri[2].y = mat.rows;
    srcTri[3].x = src[3].x;
    srcTri[3].y = src[3].y;
    dstTri[3].x = mat.cols;
    dstTri[3].y = 0;
    
    cv::Mat perspective_matrix = cv::getPerspectiveTransform(srcTri, dstTri);
    cv::warpPerspective(mat, mat, perspective_matrix, mat.size(), cv::INTER_LINEAR);
    
    return MatToUIImage(mat);
}


/*
 cv::Mat dst_img, work_img;
 dst_img = src_img.clone();
 
 cv::Canny(work_img, work_img, 50, 200, 3);
 
 // （古典的）Hough変換
 std::vector<cv::Vec2f> lines;
 // 入力画像，出力，距離分解能，角度分解能，閾値，*,*
 cv::HoughLines(work_img, lines, 1, CV_PI/180, 200, 0, 0);
 
 std::vector<cv::Vec2f>::iterator it = lines.begin();
 for(; it!=lines.end(); ++it) {
 float rho = (*it)[0], theta = (*it)[1];
 cv::Point pt1, pt2;
 double a = cos(theta), b = sin(theta);
 double x0 = a*rho, y0 = b*rho;
 pt1.x = cv::saturate_cast<int>(x0 + 1000*(-b));
 pt1.y = cv::saturate_cast<int>(y0 + 1000*(a));
 pt2.x = cv::saturate_cast<int>(x0 - 1000*(-b));
 pt2.y = cv::saturate_cast<int>(y0 - 1000*(a));
 cv::line(dst_img, pt1, pt2, cv::Scalar(0,0,255), 3, CV_AA);
 }
 
 cv::namedWindow("HoughLines", CV_WINDOW_AUTOSIZE|CV_WINDOW_FREERATIO);
 cv::imshow("HoughLines", dst_img);
 cv::waitKey(0);
 }
 */

//-(int)Width:(UIImage *)image {
//    
//    cv::Mat mat;
//    UIImageToMat(image, mat);
//    return  mat.cols;
//}
//
//-(int)Height:(UIImage *)image {
//    
//    cv::Mat mat;
//    UIImageToMat(image, mat);
//    //    return  mat.depth();
//    return  mat.channels();
//    
//    //depth == CV_64F, channels
//}

//-(UIImage *)CreateImage:(UIImage *)image {
//    //cv::Mat mat;
//    //UIImageToMat(image, mat);
//    
//    //int depth = mat.depth(); // 4
//    
//    cv::Mat mat(100, 200,  CV_8UC4, cv::Scalar(255, 0, 0, 100));
//    
//    //mat.convertTo(mat, CV_16UC1);
//    //    cv::blur(mat, mat, cv::Size(20,20));
//    //    for(int x=0;x<100;x++){
//    //        for(int y=0;y<100;y++){
//    //            mat.at<cv::Vec4b>(y, x)[0] = 255; //RED
//    //            mat.at<cv::Vec4b>(y, x)[1] = 0; //GREEN
//    //            mat.at<cv::Vec4b>(y, x)[2] = 0; //BLUE
//    //            mat.at<cv::Vec4b>(y, x)[3] = 100; //ALPHA
//    //        }
//    //    }
//    return MatToUIImage(mat);
//}


@end

