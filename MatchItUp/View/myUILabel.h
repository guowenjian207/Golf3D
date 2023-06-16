//
//  myUILabel.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/6/20.
//

#import <UIKit/UIKit.h>
typedef enum
{
 VerticalAlignmentTop = 0, // default
 VerticalAlignmentMiddle,
 VerticalAlignmentBottom,
} VerticalAlignment;
@interface myUILabel : UILabel
{
@private
VerticalAlignment _verticalAlignment;
}
@property (nonatomic) VerticalAlignment verticalAlignment;
@end 
