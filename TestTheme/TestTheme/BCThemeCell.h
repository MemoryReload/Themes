//
//  BCThemeCell.h
//  TestTheme
//
//  Created by HePing on 13-12-13.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemesManager.h"

@interface BCThemeCell : UITableViewCell <ThemeDownloadDelegate>
{
    Theme* theme;
    UIProgressView* progress;
    UIButton* downloadBtn;
    UILabel* errorLabel;
    UIImageView* bgImgView;
    UIImageView* selectedBgView;
    BOOL displayDownloadButton;
}

@property (strong,nonatomic) Theme* theme;
@property (assign,nonatomic) BOOL displayDownloadButton;
@end
