//
//  ThemeDownloadDelegate.h
//  Themes
//
//  Created by HePing on 13-11-26.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Theme;
@protocol ThemeDownloadDelegate <NSObject>
@optional
-(void)didFinishDownloadTheme:(Theme*)theme WithProcess:(float) process;
-(void)didFailDownloadTheme:(Theme*)theme WithProcess:(float) process;
-(void)loadingTheme:(Theme*)theme WithProcess:(float)process;
-(void)didbeginDownloadTheme:(Theme*)theme WithProcess:(float) process;
@end
