//
//  ThemesManager.m
//  Themes
//
//  Created by HePing on 13-11-25.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import "ThemesManager.h"
#import "Theme.h"

const NSString* ApplicationThemeChangedNotification=@"ApplicationThemeChangedNotificationName";

@implementation ThemesManager

//themes directory path
+(NSString*) themesDefaultDirectoryPath
{
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirPath=[[paths lastObject] stringByAppendingPathComponent:@"Themes"];
    return dirPath;
}

//skeleton theme manager
+(ThemesManager*) sharedThemesManager
{
    static ThemesManager* defaultManager;
    if (!defaultManager) {
        NSString* plistFilePath=[[NSString alloc]initWithFormat:@"%@/ThemesList.plist",[ThemesManager themesDefaultDirectoryPath]];
        NSLog(@"configFilePath=%@",plistFilePath);
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistFilePath]) {
            defaultManager=[[ThemesManager alloc]init];
        }else{
            defaultManager=[[ThemesManager alloc]initWithFile:plistFilePath];
        }
    }
    return defaultManager;
}

//init method
-(id)init
{
    NSLog(@"init Manager firstTime >>>>>>>>>>>>>>>>");
    self=[super init];
    if (self) {
        Theme* defaultTheme=[Theme defaultTheme];
        themes=[[NSMutableArray alloc]initWithArray:@[defaultTheme]];
        selectedIndex=0;
        selectedTheme=[themes objectAtIndex:selectedIndex];
        while (![self synchronize]) {
            [NSThread sleepForTimeInterval:0.05];
        }
    }
    return self;
}

-(id)initWithFile:(NSString*)filePath
{
    NSLog(@"init Manager from configFile >>>>>>>>>>>>>>>>");
    self=[super init];
    if (self) {
        NSArray* temArray=[[NSArray alloc]initWithContentsOfFile:filePath];
        themes=[[NSMutableArray alloc]init];
          if (temArray.count>0) {
              for (NSDictionary* dic in temArray) {
                  Theme* tempTheme=[[Theme alloc]initWithThemeInfoDictionary:dic];
                  [themes addObject:tempTheme];
              }
          }else{
              NSAssert(0, @"Fatal error in 'initWithFile:' method!");
          }
        NSUserDefaults* usrDefault=[NSUserDefaults standardUserDefaults];
        selectedIndex=[[usrDefault valueForKey:kUserSelectedThemeIndex] integerValue];
        selectedTheme=[themes objectAtIndex:selectedIndex];
    }
    return self;
}

//add and deletae operation
-(void)registTheme:(Theme*)aTheme
{
    NSAssert(aTheme, @"cannot regist a nil theme!");
    if ([themes indexOfObject:aTheme]==NSNotFound) {
        [themes addObject:aTheme];
    }
    while (![self synchronize]) {
        [NSThread sleepForTimeInterval:0.05];
    }
}

-(void)removeTheme:(Theme*)aTheme
{
    NSAssert(aTheme, @"cannot remove a nil theme!");
    NSAssert([themes indexOfObject:aTheme], @"cannot remove the defaultTheme!");
    if ([themes indexOfObject:aTheme]!=NSNotFound) {
        if (selectedIndex==themes.count-1) {
            [themes removeObject:aTheme];
            selectedIndex=selectedIndex-1;
            selectedTheme=[themes objectAtIndex:selectedIndex];
        }else{
            [themes removeObject:aTheme];
            selectedTheme=[themes objectAtIndex:selectedIndex];
        }
        while (![self synchronize]) {
            [NSThread sleepForTimeInterval:0.05];
        }
    }
}

//select operation
-(void)selectTheme:(Theme*)aTheme
{
    NSAssert(aTheme, @"cannot select a nil theme!");
    if ([themes indexOfObject:aTheme]!=NSNotFound) {
        selectedTheme=aTheme;
        selectedIndex=[themes indexOfObject:aTheme];
    }
    while (![self synchronize]) {
        [NSThread sleepForTimeInterval:0.05];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)ApplicationThemeChangedNotification object:self userInfo:@{@"selectedTheme": selectedTheme,@"selectedIndex": [NSNumber numberWithInt:selectedIndex]}];
}

-(void)selectThemeWithIndex:(NSInteger)index
{
    if (index>=0&&index<themes.count) {
        selectedIndex=index;
        selectedTheme=[themes objectAtIndex:index];
        [self synchronize];
    }
    while (![self synchronize]) {
        [NSThread sleepForTimeInterval:0.05];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)ApplicationThemeChangedNotification object:self userInfo:@{@"selectedTheme": selectedTheme,@"selectedIndex": [NSNumber numberWithInt:selectedIndex]}];
}

//wheather theme registed in themesManager
-(BOOL)isRegistedTheme:(Theme*)aTheme
{
    if ([themes indexOfObject:aTheme]!=NSNotFound) {
        return YES;
    }
    return NO;
}

//synchronization
-(BOOL)synchronize
{
    NSLog(@"synchronize>>>>>>>>>>>>>>>>");
    if (!themes||themes.count<=0)
    {
        NSAssert(0, @"Fatal Error with ThemesManager: themesList is empty!");
    }
    NSString* plistFilePath=[[NSString alloc]initWithFormat:@"%@/ThemesList.plist",[ThemesManager themesDefaultDirectoryPath]];
    NSLog(@"fileName=%@",plistFilePath);
    NSUserDefaults* usrDefalt=[NSUserDefaults standardUserDefaults];
    [usrDefalt setObject:[NSNumber numberWithInteger:selectedIndex] forKey:kUserSelectedThemeIndex];
    [usrDefalt synchronize];
    NSMutableArray* tempArray=[[NSMutableArray alloc]init];
    for (Theme* aTheme in themes) {
        NSDictionary* dic=[aTheme dictionarySerializedFromTheme:aTheme];
        [tempArray addObject:dic];
    }
    
    BOOL isDirectory;
    BOOL exit=[[NSFileManager defaultManager] fileExistsAtPath:[ThemesManager themesDefaultDirectoryPath] isDirectory:&isDirectory];
    
    if (!(exit&&isDirectory)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[ThemesManager themesDefaultDirectoryPath] withIntermediateDirectories:NO attributes:NO error:nil];
    }
    
    BOOL result=[tempArray writeToFile:plistFilePath atomically:YES];
    return result;
}

//current selected theme
-(Theme*)currentTheme
{
    return selectedTheme;
}
@end

