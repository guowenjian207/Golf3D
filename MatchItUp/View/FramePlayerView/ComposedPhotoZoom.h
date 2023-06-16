//
//  ComposedPhotoZoom.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/12/23.
//

#import <UIKit/UIKit.h>
#import "CanvasView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ComposedPhotoZoom : UIScrollView

@property (strong, nonatomic) CanvasView *canvasView;
//默认是屏幕的宽和高
@property (assign, nonatomic) CGFloat imageNormalWidth;  //图片未缩放时宽度
@property (assign, nonatomic) CGFloat imageNormalHeight; //图片未缩放时高度

- (void)pictureZoomWithScale:(CGFloat)zoomScale;

@end

NS_ASSUME_NONNULL_END
