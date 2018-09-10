//
//  WebViewCell.h
//  webdemo
//
//  Created by 曹绍奇 on 2018/8/28.
//  Copyright © 2018年 Once. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WebViewCell : UITableViewCell

@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) void(^notifyRefresh)(WKWebView *webView);

@end
