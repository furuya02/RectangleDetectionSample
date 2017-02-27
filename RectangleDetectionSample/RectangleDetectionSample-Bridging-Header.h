//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCv : NSObject

- (UIImage *)MyFunction:(UIImage *)image;
- (UIImage *)CreateImage:(UIImage *)image;
- (UIImage *)SearchLine:(UIImage *)image;

-(int)Width:(UIImage *)image;
-(int)Height:(UIImage *)image;

@property (nonatomic, strong, getter = getRects) NSArray *rects;

@end
