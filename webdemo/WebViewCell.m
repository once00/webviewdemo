//
//  WebViewCell.m
//  webdemo
//
//  Created by 曹绍奇 on 2018/8/28.
//  Copyright © 2018年 Once. All rights reserved.
//

#import "WebViewCell.h"
#import "Masonry.h"

NSString* getHtml(NSString *htm) {
    NSString *htmls = [NSString stringWithFormat:@"<html> \n"
                       "<head> \n"
                       "<meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0' name='viewport'>"
                       "<style type=\"text/css\"> \n"
                       "body {font-size:15px;}\n"
                       "</style> \n"
                       "</head> \n"
                       "<body>"
                       "<script type='text/javascript'>"
                       "window.onload = function(){\n"
                       "var $img = document.getElementsByTagName('img');\n"
                       "for(var p in  $img){\n"
                       " $img[p].style.width = '100%%';\n"
                       "$img[p].style.height ='auto'\n"
                       "}\n"
                       "}"
                       "</script>%@"
                       "</body>"
                       "</html>",htm];
    
    
    NSString *result = [NSString stringWithFormat:@"<%@ %@",@"img",@"style='display: block; max-width: 100%;'"];
    NSString * contentStr = htm;
    
    contentStr = [contentStr stringByReplacingOccurrencesOfString:@"<img" withString:result];
    
    NSString *htmlStr = [NSString stringWithFormat:@"<html><head><meta http-equiv=\'Content-Type\' content=\'text/html; charset=utf-8\'/><meta content=\'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;\' name=\'viewport\' /><meta name=\'apple-mobile-web-app-capable\' content=\'yes\'><meta name=\'apple-mobile-web-app-status-bar-style\' content=\'black\'><link rel=\'stylesheet\' type=\'text/css\' /><style type=\'text/css\'> .color{color:#576b95;}</style></head><body><div id=\'content\'>%@</div>", contentStr];
    return htmlStr;
}


@interface WebViewCell ()<WKNavigationDelegate>

@property (nonatomic,assign) BOOL needLoad;

@end

@implementation WebViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.needLoad = YES;
        [self creatUI];
    }
    return self;
}

- (void)creatUI
{
    [self.contentView addSubview:self.wkWebView];
    
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
}

- (void)setContent:(NSString *)content
{
    _content = content;
    if (self.needLoad) {
        
        NSString *htmlString = getHtml(content);
        [self.wkWebView loadHTMLString:htmlString baseURL:nil];
        self.needLoad = NO;
    }
    
}


// 页面加载完成之后调用 此方法会调用多次
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    __block CGFloat webViewHeight;
    
    //获取内容实际高度（像素）@"document.getElementById(\"content\").offsetHeight;"
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result,NSError * _Nullable error) {
        // 此处js字符串采用scrollHeight而不是offsetHeight是因为后者并获取不到高度，看参考资料说是对于加载html字符串的情况下使用后者可以(@"document.getElementById(\"content\").offsetHeight;")，但如果是和我一样直接加载原站内容使用前者更合适
        //获取页面高度，并重置webview的frame
        webViewHeight = [result doubleValue];
        // 设置webView高度
        [self.wkWebView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(webViewHeight);
        }];
        
        if (self.notifyRefresh) {
            self.notifyRefresh(webView);
        }
    }];
    
    NSLog(@"结束加载");
}

#pragma mark
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        wkWebConfig.userContentController = wkUController;
        /** << 自适应屏幕宽度js > */
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        /** << 添加js调用 > */
        [wkUController addUserScript:wkUserScript];
        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:wkWebConfig];
        //        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        _wkWebView.opaque = NO;
        _wkWebView.scrollView.scrollEnabled = NO;
        _wkWebView.scrollView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0,*)) {
            _wkWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _wkWebView.scrollView.bounces = NO;
        _wkWebView.backgroundColor = [UIColor clearColor];
    }
    return _wkWebView;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
