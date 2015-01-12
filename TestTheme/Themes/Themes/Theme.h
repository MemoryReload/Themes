//
//  Theme.h
//  Themes
//
//  Created by HePing on 13-11-25.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemesManager.h"
#import "ThemeDownloadDelegate.h"
#import "ZipArchive/ZipArchive.h"

#ifndef BC_THEME_
#define BC_THEME_
#define kThemeID            @"themeID"
#define kAuthor             @"author"
#define kBundle             @"bundle"
#define kDownloadUrl        @"downloadUrl"
#define kTittle             @"tittle"
#define kThumbUrl           @"thumbUrl"
#define kSize               @"size"
#define DefaultThemeID     @"100000001"
#define ConfigFilelName     @"ThemeConfig"
#endif

@interface Theme : NSObject <NSURLConnectionDataDelegate>
{
    NSString* themeID;
    NSString* author;
    NSString* bundle;
    NSString* downloadUrl;
    NSString* tittle;
    NSString* thumbUrl;
    float size;
    
    long long totalBytesExpected;
    NSURLRequest* request;
    NSURLConnection* connection;
    NSOperationQueue* queue;
    NSMutableData* fileData;
}

@property (readonly,nonatomic,strong) NSString* themeID;
@property (readonly,nonatomic,strong) NSString* author;
@property (readonly,nonatomic,strong) NSString* bundle;
@property (readonly,nonatomic,strong) NSString* downloadUrl;
@property (readonly,nonatomic,strong) NSString* tittle;
@property (readonly,nonatomic,strong) NSString* thumbUrl;
@property (readonly,nonatomic,assign) float size;
@property (assign,nonatomic) id<ThemeDownloadDelegate> downloadDelegate;

//init Methods
+(id)defaultTheme;
-(id)initWithThemeID:(NSString*)aThemeID Author:(NSString*)aAuthor bundle:(NSString*)aBundle DownloadURL:(NSString*)aDownloadUrl Tittle:(NSString*)aTittle ThumbUrl:(NSString*)aThumbUrlStr Size:(float)aSize;
-(id)initWithThemeInfoDictionary:(NSDictionary*)themeInfoDic;
//comparesion Method
-(BOOL)isEqual:(Theme*)anotheTheme;
//serialize Method
-(NSDictionary*)dictionarySerializedFromTheme:(Theme*)aThemel;
//ThemeDownload
-(void)download;
//ThemeConfigInfo
-(id)configInfoForKeyPath:(NSString*)keyPath;
-(UIColor*)colorItemForKeyPath:(NSString*)keyPath;
-(CGPoint)pointItemForKeyPath:(NSString*)keyPath;
-(CGRect)rectItemForKeyPath:(NSString*)keyPath;
-(UIImage*)imageItemForName:(NSString*)imgName ofType:(NSString*)imageType;
@end
