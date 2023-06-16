//
//  RootTabbarController.m
//  MatchItUp
//
//  Created by 安子和 on 2020/12/25.
//

#import "RootTabbarController.h"
#import "CameraViewController.h"
#import "AlbumViewController.h"
#import "ModelPlayController.h"
@interface RootTabbarController ()

@end

@implementation RootTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UIScreen.mainScreen.bounds.size.width
    self.view.backgroundColor=[UIColor blackColor];
    [self addChildViewControllers];
    self.tabBar.backgroundColor = [UIColor blackColor];
    [self.tabBar setBarTintColor:[UIColor blackColor]];
    self.tabBar.tintColor = [UIColor whiteColor];
    self.selectedIndex = 0;
}

- (void)addChildViewControllers {
    //3D ModelPlay
    [self addModelPlayViewController];
    //相册
    [self addAlbumViewController];
    
    [self addCameraViewController];
}
- (void)addModelPlayViewController{
    UINavigationController *navigationControler = [[UINavigationController alloc]init];
    [navigationControler.navigationBar setTitleTextAttributes:@{
        NSFontAttributeName : [GlobalVar sharedInstance].titleFont,
        //NSForegroundColorAttributeName : UIColor.lightGrayColor
    }];
    UIImage *img = [UIImage imageNamed:@"modelView"];
    navigationControler.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:img selectedImage:img];
    ModelPlayController *vc = [[ModelPlayController alloc] init];
    [navigationControler pushViewController:vc animated:NO];
    [self addChildViewController:navigationControler];
}

- (void)addAlbumViewController{
    UINavigationController *navigationControler = [[UINavigationController alloc]init];
    [navigationControler.navigationBar setTitleTextAttributes:@{
        NSFontAttributeName : [GlobalVar sharedInstance].titleFont,
        //NSForegroundColorAttributeName : UIColor.lightGrayColor
    }];
    UIImage *img = [UIImage imageNamed:@"analyzer"];
    navigationControler.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"" image:img selectedImage:img];
    
    AlbumViewController *vc = [[AlbumViewController alloc]init];
    [navigationControler pushViewController:vc animated:NO];
    [self addChildViewController:navigationControler];
}

- (void)addCameraViewController{
    UINavigationController *navigationControler = [[UINavigationController alloc]init];
    [navigationControler.navigationBar setTitleTextAttributes:@{
        NSFontAttributeName : [GlobalVar sharedInstance].titleFont,
        //NSForegroundColorAttributeName : UIColor.lightGrayColor
    }];
    UIImage *img = [UIImage imageNamed:@"analyzer"];
    navigationControler.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"" image:img selectedImage:img];
    
    CameraViewController *vc = [[CameraViewController    alloc]init];
    [navigationControler pushViewController:vc animated:NO];
    [self addChildViewController:navigationControler];
}
@end
