//
//  UIDevice+WJDevice.m
//  MatchItUp
//
//  Created by GWJ on 2022/10/26.
//

#import "UIDevice+WJDevice.h"

@implementation UIDevice (WJDevice)
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
}
@end
