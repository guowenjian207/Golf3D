//
//  ShowFramesViewController.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/7/28.
//

#import "ShowFramesViewController.h"
//#import "LineLayout.h"
//#import "ShowFrameCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "FrameSetView.h"
#import "FramePhotoZoom.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "NSFileManager+Category.h"
#import "ComposedPhotoZoom.h"

@interface ShowFramesViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, strong) ComposedPhotoZoom *composedPhotoZoomView;
@property (nonatomic, strong) NSMutableArray *photoZoomViews;
@property (nonatomic, strong) UIButton *canvasBtn;

@end

@implementation ShowFramesViewController {
    NSInteger index;
    FrameSetView *frameSetView;
    MBProgressHUD *hud;
    BOOL hasUploaded;
    UIButton *uploadBtn;
    NSMutableString *MD5Code;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    hasUploaded = false;
    [self checkIfHasUploaded];
}

- (NSMutableArray *)photoZoomViews {
    if (!_photoZoomViews) {
        _photoZoomViews = [[NSMutableArray alloc] init];
    }
    return _photoZoomViews;
}

- (instancetype)initViewWithSelectedFrames:(NSMutableArray *)frames andRate:(float)Rate
{
    self = [super init];
    if (self) {
        _videoWidthAndHeightRate = Rate;
        self.frames = frames;
        self.automaticallyAdjustsScrollViewInsets = NO;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = FALSE; //垂直滚动条
        _scrollView.showsHorizontalScrollIndicator = FALSE;//水平滚动条
        [self.view addSubview:_scrollView];
        
        self.canvasBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.canvasBtn.backgroundColor = [UIColor blackColor];
        [self.canvasBtn setTitle:@"画布" forState:UIControlStateNormal];
        [self.canvasBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.canvasBtn addTarget:self action:@selector(showCanvas) forControlEvents:UIControlEventTouchUpInside];
        
        _scrollView.contentSize = CGSizeMake(14 * self.view.frame.size.width, self.view.frame.size.height);
        frameSetView = [[FrameSetView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height - self.view.bounds.size.width) / 2, self.view.bounds.size.width, self.view.bounds.size.width) andFrameSet:frames andRate:_videoWidthAndHeightRate];
        _composedPhotoZoomView = [[ComposedPhotoZoom alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, self.view.bounds.size.height - 70)];
        _composedPhotoZoomView.imageNormalWidth = self.view.frame.size.width;
        _composedPhotoZoomView.imageNormalHeight = self.view.frame.size.width;
        [_scrollView addSubview:_composedPhotoZoomView];
        [self.view addSubview:frameSetView];
        _composedPhotoZoomView.canvasView.imageView.image = [self convertViewToImage:frameSetView];
        [frameSetView setHidden:YES];
        
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"13帧合成图";
        [_scrollView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(40);
                    make.bottom.mas_equalTo(_composedPhotoZoomView.mas_top);
                    make.left.width.equalTo(_composedPhotoZoomView);
        }];
        
        [_scrollView addSubview:_canvasBtn];
        [self.canvasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(40);
                make.width.mas_equalTo(100);
                make.bottom.mas_equalTo(_composedPhotoZoomView.mas_top);
                make.left.equalTo(_composedPhotoZoomView);
        }];
        
        uploadBtn = [[UIButton alloc] init];
        [uploadBtn setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
        [uploadBtn addTarget:self action:@selector(uploadVideoAndFrames) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:uploadBtn];
        [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.width.mas_equalTo(40);
                    make.bottom.mas_equalTo(_composedPhotoZoomView.mas_top);
                    make.right.equalTo(_composedPhotoZoomView);
        }];
        
        for (int i = 0; i < 13; i++) {
            UIImage *tmpImage;
            if ([frames[i] isKindOfClass:[UIImage class]]) {
                tmpImage = frames[i];
            }
            else {
                tmpImage = [self imageWithColor:[UIColor whiteColor]];
            }
            
            FramePhotoZoom *photoZoomView = [[FramePhotoZoom alloc] initWithFrame:CGRectMake((i + 1) * self.view.frame.size.width, 70, self.view.frame.size.width, self.view.frame.size.height - 70)];
            photoZoomView.imageNormalWidth = self.view.frame.size.width - 40;
            photoZoomView.imageNormalHeight = (self.view.frame.size.width - 40) / _videoWidthAndHeightRate;
            photoZoomView.imageView.image = tmpImage;
            [_scrollView addSubview:photoZoomView];
            /*
            UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake((i + 1) * self.view.frame.size.width + 20, 95, self.view.frame.size.width - 40, self.view.frame.size.height - 190)];
            tmpImageView.image = tmpImage;
            [_scrollView addSubview:tmpImageView];
             */
            //[self.photoZoomViews addObject:tmpImageView];
            [self.photoZoomViews addObject:photoZoomView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((i + 1) * self.view.frame.size.width, 30, self.view.frame.size.width, 40)];
            label.backgroundColor = [UIColor blackColor];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [NSString stringWithFormat:@"第 %d 帧", i + 1];
            [_scrollView addSubview:label];
            
            UIButton *btn = [[UIButton alloc] init];
            btn.backgroundColor = [UIColor clearColor];
            [btn setImage:[UIImage imageNamed:@"deleteFrame"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(deleteFrame:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            btn.frame = CGRectMake((i + 1) * self.view.frame.size.width + self.view.frame.size.width - 20 - 40, 30, 40, 40);
            [_scrollView addSubview:btn];
        }
    }
    return self;
}

//使用该方法不会模糊，根据屏幕密度计算
- (UIImage *)convertViewToImage:(UIView *)view {
    UIImage *imageRet = [[UIImage alloc]init];
    //UIGraphicsBeginImageContextWithOptions(区域大小, 是否是非透明的, 屏幕密度);
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageRet;
    
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)deleteFrame:(UIButton *)sender {
    NSInteger idx = sender.tag;
    self.frames[idx] = [[NSObject alloc] init];
    
    [frameSetView removeFromSuperview];
    frameSetView = [[FrameSetView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height - self.view.bounds.size.width) / 2, self.view.bounds.size.width, self.view.bounds.size.width) andFrameSet:_frames andRate:_videoWidthAndHeightRate];
    [self.view addSubview:frameSetView];
    _composedPhotoZoomView.canvasView.imageView.image = [self convertViewToImage:frameSetView];
    [frameSetView setHidden:YES];
    NSNumber *number = [NSNumber numberWithInt:(int)idx];
    NSNotification *notification = [NSNotification notificationWithName:@"deleteFrameAtIndex" object:nil userInfo:@{@"index":number}];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
    
    /*
    UIImage *tmpImage = [self imageWithColor:[UIColor whiteColor]];
    UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake((idx + 1) * self.view.frame.size.width + 20, 95, self.view.frame.size.width - 40, self.view.frame.size.height - 190)];
    tmpImageView.image = tmpImage;
     */
    
    /*
    FramePhotoZoom *photoZoomView = [[FramePhotoZoom alloc] initWithFrame:CGRectMake((idx + 1) * self.view.frame.size.width, 70, self.view.frame.size.width, self.view.frame.size.height - 70)];
    photoZoomView.imageNormalWidth = self.view.frame.size.width - 40;
    photoZoomView.imageNormalHeight = self.view.frame.size.height - 190;
    photoZoomView.imageView.image = [self imageWithColor:[UIColor whiteColor]];
    // [_scrollView addSubview:photoZoomView];
    
    [self.photoZoomViews[idx] removeFromSuperview];
    //[_scrollView insertSubview:tmpImageView atIndex:3 * idx + 2];
    //self.photoZoomViews[idx] = tmpImageView;
    [_scrollView insertSubview:photoZoomView atIndex:3 * idx + 4];
    self.photoZoomViews[idx] = photoZoomView;*/
    ((FramePhotoZoom *)self.photoZoomViews[idx]).imageView.image = [self imageWithColor:[UIColor whiteColor]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger scrollIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (scrollIndex != index) {
        //重置上一个缩放过的视图
        FramePhotoZoom *zoomView;
        if (index) {
            zoomView  = (FramePhotoZoom *)scrollView.subviews[(index - 1) * 3 + 4];
        }
        else {
            zoomView  = (FramePhotoZoom *)scrollView.subviews[0];
        }
        [zoomView pictureZoomWithScale:1.0f];
        index = scrollIndex;
    }
}

//开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    index = round(scrollView.contentOffset.x / scrollView.frame.size.width);
}

- (void)showCanvas {
    
}

- (void)uploadVideoAndFrames {
    // 上传视频和帧号
    for (int i = 0; i < 13; i++) {
        if (![_frames[i] isKindOfClass:[UIImage class]]) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] init];
            hud.mode = MBProgressHUDModeText;
            [self.view addSubview:hud];
            [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_offset(150);
                    make.height.mas_equalTo(80);
                    make.center.equalTo(self.view);
            }];
            [hud showAnimated:YES];
            hud.label.text = [NSString stringWithFormat:@"未选择第 %d 帧关键帧", i + 1];
            [hud hideAnimated:YES afterDelay:1];
            return ;
        }
    }
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"上传中...";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *stringParam = [self.selectedFramesIndex componentsJoinedByString:@","];
    
    if (hasUploaded) {
        [manager POST:@"http://s11.bupt.cc:37578/upload/frames" parameters:@{@"frames":stringParam, @"md5":MD5Code} headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->hud.progress = uploadProgress.fractionCompleted;
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseObject[@"code"] intValue] == 200) {
                    [self->hud hideAnimated:YES];
                    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                    hud.mode = MBProgressHUDModeText;
                    [self.view addSubview:hud];
                    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_offset(150);
                            make.height.mas_equalTo(80);
                            make.center.equalTo(self.view);
                    }];
                    [hud showAnimated:YES];
                    hud.label.text = @"上传成功";
                    [hud hideAnimated:YES afterDelay:1];
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            [self->hud hideAnimated:YES];
            if (error.code == -1002 || error.code == -1003) {
                MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                hud.mode = MBProgressHUDModeText;
                [self.view addSubview:hud];
                [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_offset(150);
                        make.height.mas_equalTo(80);
                        make.center.equalTo(self.view);
                }];
                [hud showAnimated:YES];
                hud.label.text = @"上传失败，请检查服务器连接";
                [hud hideAnimated:YES afterDelay:1];
            }
            else if (error.code == -1009) {
                MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                hud.mode = MBProgressHUDModeText;
                [self.view addSubview:hud];
                [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_offset(150);
                        make.height.mas_equalTo(80);
                        make.center.equalTo(self.view);
                }];
                [hud showAnimated:YES];
                hud.label.text = @"上传失败，请检查网络连接";
                [hud hideAnimated:YES afterDelay:1];
            }
        }];
        return;
    }
    
    [manager POST:@"http://s11.bupt.cc:37578/upload/file" parameters:@{@"frames":stringParam, @"md5":MD5Code} headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileURL:self.videoUrl name:@"file" error:nil];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->hud.progress = uploadProgress.fractionCompleted;
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseObject[@"code"] intValue] == 200) {
                    [self->hud hideAnimated:YES];
                    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                    hud.mode = MBProgressHUDModeText;
                    [self.view addSubview:hud];
                    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_offset(150);
                            make.height.mas_equalTo(80);
                            make.center.equalTo(self.view);
                    }];
                    [hud showAnimated:YES];
                    hud.label.text = @"上传成功";
                    [hud hideAnimated:YES afterDelay:1];
                    [self->uploadBtn setImage:[UIImage imageNamed:@"hasUploaded"] forState:UIControlStateNormal];
                    self->hasUploaded = true;
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            [self->hud hideAnimated:YES];
            if (error.code == -1002 || error.code == -1003) {
                MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                hud.mode = MBProgressHUDModeText;
                [self.view addSubview:hud];
                [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_offset(150);
                        make.height.mas_equalTo(80);
                        make.center.equalTo(self.view);
                }];
                [hud showAnimated:YES];
                hud.label.text = @"上传失败，请检查服务器连接";
                [hud hideAnimated:YES afterDelay:1];
            }
            else if (error.code == -1009) {
                MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                hud.mode = MBProgressHUDModeText;
                [self.view addSubview:hud];
                [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_offset(150);
                        make.height.mas_equalTo(80);
                        make.center.equalTo(self.view);
                }];
                [hud showAnimated:YES];
                hud.label.text = @"上传失败，请检查网络连接";
                [hud hideAnimated:YES afterDelay:1];
            }
        }];
}

-(void)checkIfHasUploaded {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    MD5Code = [[NSFileManager md5HashOfPath:[_videoUrl path]] mutableCopy];
    [MD5Code appendString:@"."];
    [MD5Code appendString:[[_videoUrl path] pathExtension]];
    [manager GET:@"http://s11.bupt.cc:37578/upload/isExist" parameters:@{@"fileName":MD5Code} headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseObject[@"code"] intValue] == 200) {}
                else {
                    [self->uploadBtn setImage:[UIImage imageNamed:@"hasUploaded"] forState:UIControlStateNormal];
                    self->hasUploaded = true;
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"查询失败");
        }];
}

@end
