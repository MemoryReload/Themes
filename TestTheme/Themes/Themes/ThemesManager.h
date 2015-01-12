//
//  ThemesManager.h
//  Themes
//
//  Created by HePing on 13-11-25.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Theme.h"

#ifndef BC_THEMESMANGER_
#define BC_THEMESMANGER_
#define kUserSelectedThemeIndex @"UserDefault_SlectedThemeIndex"
#endif

extern NSString* ApplicationThemeChangedNotification;

@class Theme;
@interface ThemesManager : NSObject
{
    NSMutableArray* themes;
    NSInteger selectedIndex;
    Theme* selectedTheme;
}

//themes directory path
+(NSString*)themesDefaultDirectoryPath;
//skeleton theme manager
+(ThemesManager*) sharedThemesManager;
//init method
-(id)init;
-(id)initWithFile:(NSString*)filePath;
//add and deletae operation
-(void)registTheme:(Theme*)aTheme;
-(void)removeTheme:(Theme*)aTheme;
//select operation
-(void)selectTheme:(Theme*)aTheme;
-(void)selectThemeWithIndex:(NSInteger)index;
//wheather theme registed in themesManager
-(BOOL)isRegistedTheme:(Theme*)aTheme;
//synchronization
-(BOOL)synchronize;
//current selected theme
-(Theme*)currentTheme;
@end
