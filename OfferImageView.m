//
//  OfferImageView.m
//  tryngo
//
//  Created by michail on 06/04/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "OfferImageView.h"
#import "UserDataSingleton.h"
#import "FONT.h"

@implementation OfferImageView {
    UIDevice *currentDevice;
}

- (id)initWithFrame:(CGRect)frame andImageName:(NSString *)imageName;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        currentDevice = [UIDevice currentDevice];
        CGRect sizeTitleView;
        sizeTitleView.origin.x = 0;
        sizeTitleView.origin.y = 20;
        sizeTitleView.size.width = self.frame.size.width;
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            sizeTitleView.size.height = 50;
        }
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            sizeTitleView.size.height = 80;
        }
        UIView *titleView = [[UIView alloc] initWithFrame:sizeTitleView];
        [titleView setBackgroundColor:[UIColor colorWithRed:77.0f/255.0f green:178.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
        [self addSubview:titleView];
        
        UIFont *buttonFont;
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            buttonFont = [FONT regularFontWithSize:15];
        }
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            buttonFont = [FONT boldFontWithSize:25];
        }
        
        UIImage *elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"button_back%@", [UserDataSingleton sharedSingleton].Sufix]];
        
        CGRect sizeButtons;
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            sizeButtons.origin.x = 20;
        }
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            sizeButtons.origin.x = 40;
        }
        sizeButtons.size.width = elementImage.size.width / 2;
        sizeButtons.size.height = elementImage.size.height / 2;
        sizeButtons.origin.y = (titleView.frame.size.height - sizeButtons.size.height) / 2;
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [backButton setFrame:sizeButtons];
        [backButton setTitle:@"BACK" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [backButton.titleLabel setFont:buttonFont];
        [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
        [backButton setBackgroundImage:elementImage forState:UIControlStateNormal];
        [titleView addSubview:backButton];
        
        NSLog(@"bigOfferString = %@", imageName);
        NSRange range = [imageName rangeOfString:@"&w=100&h=100&q=100"];
        NSString *path = [imageName substringWithRange:NSMakeRange(0, imageName.length - range.length)];
        range = [path rangeOfString:@"https://www.tryngo.ch/timthumb.php?src="];
        path = [path substringFromIndex:range.length];
        NSLog(@"path = %@", path);
        
        CGRect sizeImageView = self.frame;
        sizeImageView.origin.y = titleView.frame.origin.y + titleView.frame.size.height;
        sizeImageView.size.height -= sizeImageView.origin.y;
        
        UIWebView *webView = [[UIWebView alloc]initWithFrame:sizeImageView];
        webView.delegate = self;
        [webView setScalesPageToFit:YES];
        NSURL *nsurl=[NSURL URLWithString:path];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        [webView loadRequest:nsrequest];
        [self addSubview:webView];
    }
    return self;
}

-(void)pressBackButton {
    [self.delegate removeOfferImage];
}

@end
