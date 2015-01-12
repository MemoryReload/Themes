//
//  Theme.m
//  Themes
//
//  Created by HePing on 13-11-25.
//  Copyright (c) 2013年 HePing. All rights reserved.
//

#import "Theme.h"

@implementation Theme
@synthesize themeID;
@synthesize author;
@synthesize bundle;
@synthesize downloadUrl;
@synthesize tittle;
@synthesize thumbUrl;
@synthesize size;
@synthesize downloadDelegate;

//init Methods
static Theme* defaultTheme;
+(id)defaultTheme
{
    if (!defaultTheme) {
        defaultTheme=[[Theme alloc]initWithThemeID:DefaultThemeID Author:nil bundle:@"default" DownloadURL:nil Tittle:@"默认主题" ThumbUrl:@"" Size:0];
    }
    return defaultTheme;
}

-(id)init
{
    NSAssert(0, @"Fatal error!cannot intialize a Theme instance with 'init' method.");
    return nil;
}

-(id)initWithThemeID:(NSString*)aThemeID Author:(NSString*)aAuthor bundle:(NSString*)aBundle DownloadURL:(NSString*)aDownloadUrl Tittle:(NSString*)aTittle ThumbUrl:(NSString*)aThumbUrlStr Size:(float)aSize
{
    self=[super init];
    if (self) {
        if (aThemeID) {
            themeID=[[NSString alloc]initWithString:aThemeID];
        }else{
            NSAssert(0, @"themeID cannot be nil!");
        }
        
        if (aAuthor) {
            author=[[NSString alloc]initWithString:aAuthor];
        }else{
            author=@"";
        }
        
        if (aBundle) {
            bundle=[[NSString alloc]initWithFormat:@"Theme.%@",aBundle];
        }else{
           NSAssert(0, @"themeBundle cannot be nil!");
        }
        
        if (aDownloadUrl) {
            downloadUrl=[[NSString alloc]initWithString:aDownloadUrl];
        }else{
            downloadUrl=@"";
        }
        
        if (aTittle) {
            tittle=[[NSString alloc]initWithString:aTittle];
        }else{
            NSAssert(0, @"themeTittle cannot be nil!");
        }
        
        if (aThumbUrlStr) {
            thumbUrl=[[NSString alloc]initWithString:aThumbUrlStr];
        }else{
            thumbUrl=@"";
        }
        size=aSize;
    }
    return self;
}

-(id)initWithThemeInfoDictionary:(NSDictionary*)themeInfoDic
{
    self=[super init];
    if (self) {
        if (themeInfoDic) {
            themeID=[[NSString alloc]initWithString:[themeInfoDic objectForKey:kThemeID]];
            bundle=[[NSString alloc]initWithString:[themeInfoDic objectForKey:kBundle]];
            author=[[NSString alloc]initWithString:[themeInfoDic objectForKey:kAuthor]];
            downloadUrl=[[NSString alloc]initWithString:[themeInfoDic objectForKey:kDownloadUrl]];
            tittle=[[NSString alloc]initWithString:[themeInfoDic objectForKey:kTittle]];
            thumbUrl=[[NSString alloc]initWithString:[themeInfoDic objectForKey:kThumbUrl]];
            size=[[themeInfoDic objectForKey:kSize] floatValue];
        }else{
            NSAssert(0, @"initWithThemeInfoDictionary:   Parameters can not be nil!");
        }
    }
    return self;
}

//serialize Methd
-(NSDictionary*)dictionarySerializedFromTheme:(Theme*)aThemel
{
    NSMutableDictionary* dic=[[NSMutableDictionary alloc]init];
    if (self.themeID) {
        [dic setObject:self.themeID forKey:kThemeID];
    }else{
        [dic setObject:@"" forKey:kThemeID];
    }
    
    if (self.bundle) {
        [dic setObject:self.bundle forKey:kBundle];
    }else{
        [dic setObject:@"" forKey:kBundle];
    }
    
    if (self.author) {
        [dic setObject:self.author forKey:kAuthor];
    }else{
        [dic setObject:@"" forKey:kAuthor];
    }
    
    if (self.downloadUrl) {
        [dic setObject:self.downloadUrl forKey:kDownloadUrl];
    }else{
        [dic setObject:@"" forKey:kDownloadUrl];
    }
    
    if (self.tittle) {
        [dic setObject:self.tittle forKey:kTittle];
    }else{
        [dic setObject:@"" forKey:kTittle];
    }
    
    if (self.thumbUrl) {
        [dic setObject:self.thumbUrl forKey:kThumbUrl];
    }else{
        [dic setObject:@"" forKey:kThumbUrl];
    }
    
    if (self.size) {
        [dic setObject:[NSNumber numberWithFloat:self.size] forKey:kSize];
    }else{
        [dic setObject:[NSNumber numberWithFloat:0] forKey:kSize];
    }
    
    return dic;
}

//compare Methods
-(BOOL)isEqual:(Theme*)anotheTheme
{
        if ([self.themeID isEqualToString:anotheTheme.themeID]) {
        return YES;
    }
         return NO;
}

//ThemeDownload
-(void)download
{
    if (!request) {
        request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:downloadUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:300];
            }
    if (!queue) {
        queue=[[NSOperationQueue alloc]init];
    }
    
    if (connection) {
        [connection cancel];
    }
    
    connection=[[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
    [connection setDelegateQueue:queue];
    [connection start];
}

//ThemeConfigInfo
-(id)configInfoForKeyPath:(NSString*)keyPath
{
    NSDictionary* configDic;
    NSString* configFilePath;
    if ([self isEqual:[Theme defaultTheme]]) {
        configFilePath=[[NSBundle mainBundle] pathForResource:ConfigFilelName ofType:@"plist"];
    }else{
        configFilePath=[[NSString alloc]initWithFormat:@"%@/%@/%@.plist",[ThemesManager themesDefaultDirectoryPath],self.bundle,ConfigFilelName];
        NSLog(@"filePath=%@",configFilePath);
    }
    configDic=[[NSDictionary alloc]initWithContentsOfFile:configFilePath];
    return [configDic valueForKeyPath:keyPath];
}

-(UIColor*)colorItemForKeyPath:(NSString*)keyPath
{
    NSString* colorStr=[self configInfoForKeyPath:keyPath];
    
    NSMutableCharacterSet* skipSet=[NSCharacterSet characterSetWithCharactersInString:@","];
    [skipSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSScanner* scanner=[NSScanner scannerWithString:colorStr];
    [scanner setCharactersToBeSkipped:skipSet];
    
    NSUInteger m[3]={0,0,0};
    CGFloat alph=0;
    for (NSInteger i=0; i<3; i++){
        [scanner scanHexInt:m+i];
    }
    [scanner scanFloat:&alph];
    
    UIColor* color=[[UIColor alloc]initWithRed:m[0]/255.0f green:m[1]/255.0f blue:m[2]/255.0f alpha:alph];
    return color;
}

-(UIImage*)imageItemForName:(NSString*)imgName ofType:(NSString*)imageType
{
    NSString* imgFilePath;
    UIImage* img;
    if ([self isEqual:[Theme defaultTheme]]) {
        imgFilePath=[[NSBundle mainBundle] pathForResource:imgName ofType:imageType];
    }else{
        imgFilePath=[[NSString alloc]initWithFormat:@"%@/%@/%@.%@",[ThemesManager themesDefaultDirectoryPath],self.bundle,imgName,imageType];
        NSLog(@"filePath=%@",imgFilePath);
    }
    img=[[UIImage alloc]initWithContentsOfFile:imgFilePath];
    return img;
}

-(CGPoint)pointItemForKeyPath:(NSString*)keyPath
{
    NSString* pointStr=[self configInfoForKeyPath:keyPath];
    
    NSMutableCharacterSet* skipSet=[NSCharacterSet characterSetWithCharactersInString:@"{,}"];
    [skipSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSScanner* scanner=[NSScanner scannerWithString:pointStr];
    [scanner setCharactersToBeSkipped:skipSet];
    
    CGFloat m[2]={0,0};
    NSInteger i=0;
    while (![scanner isAtEnd]) {
        [scanner scanFloat:m+i];
        i++;
    }
    CGPoint point=CGPointMake(m[0], m[1]);
    return point;
}

-(CGRect)rectItemForKeyPath:(NSString*)keyPath
{
    NSString* rectStr=[self configInfoForKeyPath:keyPath];
    
    NSMutableCharacterSet* skipSet=[NSCharacterSet characterSetWithCharactersInString:@"{,}"];
    [skipSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSScanner* scanner=[NSScanner scannerWithString:rectStr];
    [scanner setCharactersToBeSkipped:skipSet];
    
    CGFloat m[4]={0,0,0,0};
    NSInteger i=0;
    while (![scanner isAtEnd]) {
        [scanner scanFloat:m+i];
        i++;
    }
    CGRect rect=CGRectMake(m[0], m[1], m[2], m[3]);
    return rect;
}
#pragma mark - Download Connection Delegate Method
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (downloadDelegate&&[downloadDelegate respondsToSelector:@selector(didFailDownloadTheme:WithProcess:)]) {
        NSMethodSignature* signature=[[downloadDelegate class] instanceMethodSignatureForSelector:@selector(didFailDownloadTheme:WithProcess:)];
        NSInvocation* invocation=[NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:@selector(didFailDownloadTheme:WithProcess:)];
        Theme* p=self;
        [invocation setTarget:downloadDelegate];
        [invocation setArgument:&p atIndex:2];
        float process=fileData.length*1.0f/totalBytesExpected;
        [invocation setArgument:&process atIndex:3];
        [invocation retainArguments];
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    totalBytesExpected=response.expectedContentLength;
    fileData=[[NSMutableData alloc]init];
    if (downloadDelegate&&[downloadDelegate respondsToSelector:@selector(didbeginDownloadTheme:WithProcess:)]) {
        NSMethodSignature* signature=[[downloadDelegate class] instanceMethodSignatureForSelector:@selector(didbeginDownloadTheme:WithProcess:)];
        NSInvocation* invocation=[NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:@selector(didbeginDownloadTheme:WithProcess:)];
        Theme* p=self;
        [invocation setTarget:downloadDelegate];
        [invocation setArgument:&p atIndex:2];
        float process=0;
        [invocation setArgument:&process atIndex:3];
        [invocation retainArguments];
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fileData appendData:data];
    long long recievedDataLength=fileData.length;
    float process=recievedDataLength*1.0f/totalBytesExpected;
    
    if ([downloadDelegate respondsToSelector:@selector(loadingTheme:WithProcess:)]) {
        NSMethodSignature* signature=[[downloadDelegate class] instanceMethodSignatureForSelector:@selector(loadingTheme:WithProcess:)];
        NSInvocation* invocation=[NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:@selector(loadingTheme:WithProcess:)];
        Theme* p=self;
        [invocation setTarget:downloadDelegate];
        [invocation setArgument:&p atIndex:2];
        [invocation setArgument:&process atIndex:3];
        [invocation retainArguments];
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString* sourcePath=[[NSString alloc] initWithFormat:@"%@%@.zip",NSTemporaryDirectory(),bundle];
    NSString* destinationPath=[[NSString alloc] initWithFormat:@"%@/%@",[ThemesManager themesDefaultDirectoryPath],bundle];
    [fileData writeToFile:sourcePath atomically:YES];
    
    ZipArchive* zipper=[[ZipArchive alloc]init];
    
    if ([zipper UnzipOpenFile:sourcePath]&&[zipper UnzipFileTo:destinationPath overWrite:YES]) {
        [zipper UnzipCloseFile];
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
    if (downloadDelegate&&[downloadDelegate respondsToSelector:@selector(didFinishDownloadTheme:WithProcess:)]) {
        NSMethodSignature* signature=[[downloadDelegate class] instanceMethodSignatureForSelector:@selector(didFinishDownloadTheme:WithProcess:)];
        NSInvocation* invocation=[NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:downloadDelegate];
        [invocation setSelector:@selector(didFinishDownloadTheme:WithProcess:)];
        Theme* p=self;
        [invocation setArgument:&p atIndex:2];
        float process=fileData.length*1.0f/totalBytesExpected;
        [invocation setArgument:&process atIndex:3];
        [invocation retainArguments];
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
                }
    }else{
        [zipper UnzipCloseFile];
        [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
        if (downloadDelegate&&[downloadDelegate respondsToSelector:@selector(didFailDownloadTheme:WithProcess:)]) {
            NSMethodSignature* signature=[[downloadDelegate class] instanceMethodSignatureForSelector:@selector(didFailDownloadTheme:WithProcess:)];
            NSInvocation* invocation=[NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:@selector(didFailDownloadTheme:WithProcess:)];
            Theme* p=self;
            [invocation setTarget:downloadDelegate];
            [invocation setArgument:&p atIndex:2];
            float process=fileData.length*1.0f/totalBytesExpected;
            [invocation setArgument:&process atIndex:3];
            [invocation retainArguments];
            [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
        }
    }
}

#pragma mark - Description
-(NSString*)description
{
   return [[NSString alloc]initWithFormat:@"<%@> {ThemeID=%@,Tittle=%@,Author=%@,Bundle=%@,Size=%f,delegate=%@,ThumbURL=%@,Download=%@}",[Theme class],themeID,tittle,author,bundle,size,[downloadDelegate class],thumbUrl,downloadUrl] ;
}

@end
