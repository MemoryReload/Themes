//
//  BCThemeCell.m
//  TestTheme
//
//  Created by HePing on 13-12-13.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import "BCThemeCell.h"

@implementation BCThemeCell
@synthesize theme;
@synthesize displayDownloadButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.frame=CGRectMake(0, 0, 320, 95);
        self.selectionStyle=UITableViewCellSelectionStyleDefault;
        
        progress=[[UIProgressView alloc]initWithFrame:CGRectMake(20, 80, 320-20*2, 10)];
        progress.hidden=YES;
        [self addSubview:progress];
        
        errorLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 40, 80, 40)];
        errorLabel.backgroundColor=[UIColor clearColor];
        errorLabel.text=@"下载失败，请检查您的网络或重试";
        errorLabel.font=[UIFont systemFontOfSize:10];
        errorLabel.textColor=[UIColor blackColor];
        errorLabel.alpha=0;
        [self addSubview:errorLabel];
        
        bgImgView=[[UIImageView alloc]initWithFrame:self.frame];
        [self setBackgroundView:bgImgView];
        selectedBgView=[[UIImageView alloc]initWithFrame:self.frame];
        selectedBgView.layer.cornerRadius=5;
        selectedBgView.layer.borderColor=[[UIColor yellowColor] CGColor];
        selectedBgView.layer.borderWidth=2;
        [self setSelectedBackgroundView:selectedBgView];
        
        downloadBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        downloadBtn.frame=CGRectMake(260,60, 45, 32);
        [downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [downloadBtn addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
        [downloadBtn setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:downloadBtn];
        
        [self setDisplayDownloadButton:YES];
        [self loadTheme];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTheme) name:ApplicationThemeChangedNotification object:nil];
    }
    return self;
}

- (void)loadTheme
{
    Theme* atheme=[[ThemesManager sharedThemesManager] currentTheme];
    [downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIImage* imgNormal=[atheme imageItemForName:@"header_btn_nor@2x" ofType:@"png"];
    UIImage* imgPress=[atheme imageItemForName:@"header_btn_press@2x" ofType:@"png"];
    [downloadBtn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [downloadBtn setBackgroundImage:imgPress forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        bgImgView=nil;
    }
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setTheme:(Theme *)aTheme
{
    if (![aTheme isEqual:theme]) {
        
        theme=aTheme;
        theme.downloadDelegate=self;
        
        if ([theme isEqual:[Theme defaultTheme]]) {
            bgImgView.image=[(Theme*)[Theme defaultTheme] imageItemForName:@"chat_bottom_bg@2x" ofType:@"png"];
            selectedBgView.image=bgImgView.image;
        }else{
            [NSThread detachNewThreadSelector:@selector(loadBgImg) toTarget:self withObject:nil];
        }
    }
}

- (void)setDisplayDownloadButton:(BOOL)displayDownload
{
    displayDownloadButton=displayDownload;
    downloadBtn.hidden=!displayDownload;
}

-(void)download
{
    [theme download];
    if (progress.progress!=0) {
        progress=0;
    }
    progress.hidden=NO;
    self.displayDownloadButton=NO;
}

-(void)loadBgImg
{
    NSString* cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* fileName=[[theme.thumbUrl componentsSeparatedByString:@"/"] lastObject];
    NSString* cacheFilePath=[cachePath stringByAppendingPathComponent:fileName];
    
    UIImage* bgImg;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        bgImg=[[UIImage alloc]initWithContentsOfFile:cacheFilePath];
    }else{
        NSData* imgData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:theme.thumbUrl]];
        bgImg=[[UIImage alloc]initWithData:imgData];
        [imgData writeToFile:cacheFilePath atomically:YES];
    }
    
    [bgImgView performSelectorOnMainThread:@selector(setImage:) withObject:bgImg waitUntilDone:NO];
    [selectedBgView performSelectorOnMainThread:@selector(setImage:) withObject:bgImg waitUntilDone:NO];
}

#pragma mark - downloadDelegate Methods
-(void)didFinishDownloadTheme:(Theme*)atheme WithProcess:(float) process
{
    progress.hidden=YES;
    [[ThemesManager sharedThemesManager] registTheme:theme];
}

-(void)didFailDownloadTheme:(Theme*)theme WithProcess:(float) process
{
    progress.hidden=YES;
    [UIView beginAnimations:@"ErrorLabelAnimation" context:nil];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:1];
    [UIView commitAnimations];
    self.displayDownloadButton=YES;
}

-(void)loadingTheme:(Theme*)theme WithProcess:(float)processing
{
    progress.progress=processing;
}

-(void)dealloc
{
    theme=nil;
    progress=nil;
    downloadBtn=nil;
    errorLabel=nil;
    bgImgView=nil;
    selectedBgView=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
