//
//  BCViewController.m
//  TestTheme
//
//  Created by HePing on 13-11-25.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import "BCViewController.h"


@interface BCViewController ()
{
    UIImageView* bgView;
    UIButton* rightButton;
    UILabel*  tittleLabel;
}
@end

@implementation BCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0){
        self.edgesForExtendedLayout=UIRectEdgeNone;
        bgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
        [self.view addSubview:bgView];
    }else{
    bgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:bgView];
    }
    
    rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame=CGRectMake(0, 0, 44, 44);
    [rightButton addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem=item;
    
    tittleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    tittleLabel.backgroundColor=[UIColor clearColor];
    tittleLabel.text=@"首页";
    tittleLabel.textAlignment=UITextAlignmentCenter;
    [self.navigationItem setTitleView:tittleLabel];
    
    [self loadTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTheme) name:ApplicationThemeChangedNotification object:nil];
}

-(void)loadTheme
{
    Theme* theme=[[ThemesManager sharedThemesManager]currentTheme];
    UIImage* image=[theme imageItemForName:@"chat_bg_default" ofType:@"jpg"];
    bgView.image=image;
    
    UIImage* btnImgNormal=[theme imageItemForName:@"chat_bottom_up_nor@2x" ofType:@"png"];
    UIImage* btnImgPressed=[theme imageItemForName:@"chat_bottom_up_press@2x" ofType:@"png"];
    [rightButton setImage:btnImgNormal forState:UIControlStateNormal];
    [rightButton setImage:btnImgPressed forState:UIControlStateHighlighted];
    
    tittleLabel.textColor=[theme colorItemForKeyPath:@"ColorTable.kNavigationBarTitleColor"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftButtonClicked
{
    BCThemeViewController* themeVC=[[BCThemeViewController alloc]init];
    [self.navigationController pushViewController:themeVC animated:YES];
}

-(void)dealloc
{
    bgView=nil;
    rightButton=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
