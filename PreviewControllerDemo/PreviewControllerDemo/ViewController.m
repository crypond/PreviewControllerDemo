//
//  ViewController.m
//  PreviewControllerDemo
//
//  Created by apple on 2017/9/29.
//  Copyright © 2017年 hty. All rights reserved.
//

#import "ViewController.h"
#import <QuickLook/QuickLook.h>
#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface ViewController () <QLPreviewControllerDataSource>

@property (strong, nonatomic)QLPreviewController *previewController;
@property (copy, nonatomic)NSURL *fileURL; //文件路径

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.previewController  =  [[QLPreviewController alloc]  init];
    self.previewController.dataSource  = self;
}

//预览本地文件
- (IBAction)previewLocal:(id)sender {
    //获取本地文件路径
    self.fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"李碧华佳句赏析.doc" ofType:nil]];
    [self presentViewController:self.previewController animated:YES completion:nil];
}

//预览网络文件
- (IBAction)previewInternet:(id)sender {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSString *urlStr = @"https://www.tutorialspoint.com/ios/ios_tutorial.pdf";
    NSString *fileName = [urlStr lastPathComponent]; //获取文件名称
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //判断是否存在
    if([self isFileExist:fileName]) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *url = [documentsDirectoryURL URLByAppendingPathComponent:fileName];
        self.fileURL = url;
        [self presentViewController:self.previewController animated:YES completion:nil];
    }else {
        [SVProgressHUD showWithStatus:@"下载中"];
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress){
            
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            NSURL *url = [documentsDirectoryURL URLByAppendingPathComponent:fileName];
            return url;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [SVProgressHUD dismiss];
            self.fileURL = filePath;
            [self presentViewController:self.previewController animated:YES completion:nil];
        }];
        [downloadTask resume];
    }
}

//判断文件是否已经在沙盒中存在
-(BOOL) isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    return result;
}

#pragma mark - QLPreviewControllerDataSource
-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.fileURL;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController{
    return 1;
}



@end
