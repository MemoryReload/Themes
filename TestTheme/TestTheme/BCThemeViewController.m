//
//  BCThemeViewController.m
//  TestTheme
//
//  Created by HePing on 13-12-12.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import "BCThemeViewController.h"

@interface BCThemeViewController ()
{
    UIButton* backButton;
    UITableView* themeTable;
    UIImageView* tableHeaderView;
    NSArray* cellsArray;
}
@end

@implementation BCThemeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.hidesBackButton=YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadThemeList];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame=CGRectMake(0, 0, 45, 32);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setFont:[UIFont systemFontOfSize:10]];
    [backButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem=item;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0){
        self.edgesForExtendedLayout=UIRectEdgeNone;
        themeTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height-[UIApplication sharedApplication].statusBarFrame.size.height) style:UITableViewStylePlain];
    }else{
        themeTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height) style:UITableViewStylePlain];
    }
    
    [themeTable setDelegate:self];
    [themeTable setDataSource:self];
    themeTable.showsHorizontalScrollIndicator=NO;
    themeTable.showsVerticalScrollIndicator=NO;
    [self.view addSubview:themeTable];
    [self initThemeTableSelection];
    
    [self loadTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTheme) name:ApplicationThemeChangedNotification object:nil];
}

- (void)loadTheme
{
    Theme* theme=[[ThemesManager sharedThemesManager] currentTheme];
    UIImage* tableBG=[theme imageItemForName:@"chat_bg_default" ofType:@"jpg"];
    themeTable.backgroundView=[[UIImageView alloc]initWithImage:tableBG];
    
    UIImage* backImgNormal=[theme imageItemForName:@"header_leftbtn_nor@2x" ofType:@"png"];
    UIImage* backImgPress=[theme imageItemForName:@"header_leftbtn_press@2x" ofType:@"png"];
    
    [backButton setBackgroundImage:backImgNormal forState:UIControlStateNormal];
    [backButton setBackgroundImage:backImgPress forState:UIControlStateHighlighted];
}

-(void)initThemeTableSelection
{
    
    NSInteger row;
    Theme* slctTheme=[[ThemesManager sharedThemesManager] currentTheme];
    for (NSInteger i=0; i<cellsArray.count; i++) {
        Theme* aTheme=[[cellsArray objectAtIndex:i] theme];
        if ([aTheme isEqual:slctTheme]) {
            row=i;
        }
    }
    NSIndexPath* indexPath=[NSIndexPath indexPathForItem:row inSection:0];
    [themeTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - TableDelegate and TableDataSource Method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"cells.count=%d",cellsArray.count);
    return cellsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BCThemeCell* cell=[cellsArray objectAtIndex:indexPath.row];
    if ([[ThemesManager sharedThemesManager] isRegistedTheme:cell.theme]) {
        cell.displayDownloadButton=NO;
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Theme* atheme=[[cellsArray objectAtIndex:indexPath.row] theme];
   BOOL registed=[[ThemesManager sharedThemesManager] isRegistedTheme:atheme];
    if (registed) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Theme* atheme=[[cellsArray objectAtIndex:indexPath.row] theme];
    [[ThemesManager sharedThemesManager] selectTheme:atheme];
}

#pragma mark - loadData Method
-(void)loadThemeList
{
    NSString* filePath=[[NSBundle mainBundle] pathForResource:@"QQThemeList" ofType:@"plist"];
    NSArray* array=[[NSArray alloc]initWithContentsOfFile:filePath];
    
    NSMutableArray* mutArray=[[NSMutableArray alloc]init];
    BCThemeCell* cell=[[BCThemeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.theme=[Theme defaultTheme];
    [mutArray addObject:cell];
    
    for (NSDictionary* dic in array) {
        NSString* themeID=[dic valueForKey:@"ThemeId"];
        NSString* author=[dic valueForKey:@"Author"];
        NSString* bundle=[dic valueForKey:@"BundleId"];
        NSString* down=[dic valueForKey:@"DownloadUrl"];
        NSString* tittle=[dic valueForKey:@"Title"];
        NSString* thumb=[dic valueForKey:@"ThumbUrl"];
        
        Theme* theme=[[Theme alloc] initWithThemeID:themeID Author:author bundle:bundle DownloadURL:down Tittle:tittle ThumbUrl:thumb Size:0];
        cell=[[BCThemeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.theme=theme;
        
        [mutArray addObject:cell];
    }
    array=nil;
    
    cellsArray=mutArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    backButton=nil;
    cellsArray=nil;
    themeTable=nil;
    tableHeaderView=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
