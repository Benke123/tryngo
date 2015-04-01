//
//  OfferTableViewCell.m
//  tryngo
//
//  Created by michail on 16/03/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "OfferTableViewCell.h"
#import "UserDataSingleton.h"
#import "FONT.h"

@implementation OfferTableViewCell {
    CGRect selfFrame;
    BOOL isCreated;
    UIImageView *offerImageView;
    UIImageView *userImageView;
//    NSMutableData *imageData;
    NSURL *url;
    NSData *offerUrlData;
    NSData *userUrlData;
}

@synthesize index;
@synthesize offerImageString;
@synthesize offerName;
@synthesize offerPlace;
@synthesize userImageString;
@synthesize userId;
@synthesize userName;
@synthesize costUnit;
@synthesize cost;
//@synthesize price;
@synthesize rating;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        selfFrame = frame;
        isCreated = false;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (!isCreated) {
        isCreated = true;
        [self create];
    }
}

-(void)create {
    UIDevice *currentDevice = [UIDevice currentDevice];
//    offerName = @"Pompe";
//    offerPlace = @"Creil, France";
//    userName = @"HATIB AYUB";
//    rating = @"0";
//    price = @"$2.00 day";
    int space = 0;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        space = 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        space = 10;
    }
    currentDevice = [UIDevice currentDevice];
/*    UIFont *textFont;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        textFont = [UIFont systemFontOfSize:15];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        textFont = [UIFont systemFontOfSize:30];
    }*/
    UIImage *elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_load_offer%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeOfferImageView;
    sizeOfferImageView.size.height = sizeOfferImageView.size.width = elementImage.size.height / 2;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeOfferImageView.origin.x = 10;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeOfferImageView.origin.x = 20;
    }
    sizeOfferImageView.origin.y = (selfFrame.size.height - sizeOfferImageView.size.height) / 2;
//    sizeOfferImageView.origin.x = sizeOfferImageView.origin.y = 10;
//    sizeOfferImageView.size.height = sizeOfferImageView.size.width = selfFrame.size.height - sizeOfferImageView.origin.y * 2;
    offerImageView = [[UIImageView alloc] initWithFrame:sizeOfferImageView];
//    [offerImageView setBackgroundColor:[UIColor magentaColor]];
//    [offerImageView setImage:offerImage];
    [offerImageView setImage:elementImage];
//    NSString *offerUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].offerImagePrefix, index, offerImageString];
    NSString *offerUrlString = [NSString stringWithFormat:@"%@/%@/%@&w=100&h=100&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, index, offerImageString];
/*    NSURL *offerUrlImage = [NSURL URLWithString:offerUrlString];
    NSData *offerDataImage = [NSData dataWithContentsOfURL:offerUrlImage];
    UIImage *offerImageFromUrl;
    if (offerDataImage) {
        offerImageFromUrl = [UIImage imageWithData:offerDataImage];
    } else {
        offerImageFromUrl = elementImage;
    }
    [offerImageView setImage:offerImageFromUrl];*/
    [self getImage:offerUrlString andType:0];
    [self addSubview:offerImageView];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_star%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeRatingView;
    sizeRatingView.size.height = elementImage.size.height / 2;
    sizeRatingView.size.width = elementImage.size.width / 2;
    sizeRatingView.origin.x = selfFrame.size.width - space * 2 - sizeRatingView.size.width;
    sizeRatingView.origin.y = offerImageView.frame.origin.y;
    for (int i = 0; i < [rating intValue]; i++) {
        UIImageView *ratingImageView = [[UIImageView alloc] initWithFrame:sizeRatingView];
        [ratingImageView setImage:elementImage];
        [self addSubview:ratingImageView];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            sizeRatingView.origin.x -= sizeRatingView.size.width + 3;
        }
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            sizeRatingView.origin.x -= sizeRatingView.size.width + 8;
        }
    }
    
    CGRect sizeOfferNameLabel;
    sizeOfferNameLabel.origin.x = offerImageView.frame.origin.x + offerImageView.frame.size.width + space;
    sizeOfferNameLabel.origin.y = offerImageView.frame.origin.y;
    sizeOfferNameLabel.size.height = offerImageView.frame.size.height / 4;
    sizeOfferNameLabel.size.width = sizeRatingView.origin.x - sizeOfferNameLabel.origin.x;
    
    UILabel *offerNameLabel = [[UILabel alloc] initWithFrame:sizeOfferNameLabel];
    [offerNameLabel setText:offerName];
    [offerNameLabel setTextColor:[UIColor colorWithRed:43.0f/255.0f green:135.0f/255.0f blue:191.0f/255.0f alpha:1.0f]];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [offerNameLabel setFont:[FONT regularFontWithSize:20]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [offerNameLabel setFont:[FONT regularFontWithSize:35]];
    }
 //   [offerNameLabel setFont:textFont];
    [self addSubview:offerNameLabel];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_geo_location%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeMapImageView;
    sizeMapImageView.size.width = elementImage.size.width / 2;
    sizeMapImageView.size.height = elementImage.size.height / 2;
    sizeMapImageView.origin.x = offerNameLabel.frame.origin.x;
    sizeMapImageView.origin.y = offerNameLabel.frame.origin.y + offerNameLabel.frame.size.height + (offerNameLabel.frame.size.height - sizeMapImageView.size.height) / 2;
    
    UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:sizeMapImageView];
    [mapImageView setImage:elementImage];
    [self addSubview:mapImageView];
    
    CGRect sizePlaceLabel;
    sizePlaceLabel.origin.x = mapImageView.frame.origin.x + mapImageView.frame.size.width + space;
    sizePlaceLabel.origin.y = mapImageView.frame.origin.y;
    sizePlaceLabel.size.height = mapImageView.frame.size.height;
    sizePlaceLabel.size.width = selfFrame.size.width - sizePlaceLabel.origin.x - space;
    
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:sizePlaceLabel];
    [placeLabel setText:offerPlace];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [placeLabel setFont:[FONT regularFontWithSize:14]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [placeLabel setFont:[FONT regularFontWithSize:24]];
    }
//    [placeLabel setFont:textFont];
    [self addSubview:placeLabel];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_user%@", [UserDataSingleton sharedSingleton].Sufix]];
//    userImage = elementImage;
    CGRect sizeUserImage;
    sizeUserImage.size.height = elementImage.size.height / 2;
    sizeUserImage.size.width = elementImage.size.width / 2;
    sizeUserImage.origin.x = offerNameLabel.frame.origin.x;
    sizeUserImage.origin.y = offerImageView.frame.origin.y + offerImageView.frame.size.height - sizeUserImage.size.height;
/*    sizeUserImage.origin.x = offerNameLabel.frame.origin.x;
    sizeUserImage.origin.y = mapImageView.frame.origin.y + mapImageView.frame.size.height;
    sizeUserImage.size.height = sizeUserImage.size.width = offerNameLabel.frame.size.height * 2;*/
    
    userImageView = [[UIImageView alloc] initWithFrame:sizeUserImage];
//    [userImageView setBackgroundColor:[UIColor magentaColor]];
    [userImageView setImage:elementImage];
    NSString *userUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].userImagePrefix, userId, userImageString];
/*    NSURL *userUrlImage = [NSURL URLWithString:userUrlString];
    NSData *userDataImage = [NSData dataWithContentsOfURL:userUrlImage];
    UIImage *userImageFromUrl;
    if (userDataImage) {
        userImageFromUrl = [UIImage imageWithData:userDataImage];
    } else {
        userImageFromUrl = elementImage;
    }
    [userImageView setImage:userImageFromUrl];*/
    [self getImage:userUrlString andType:1];
    [self addSubview:userImageView];
    
    
    UIImageView *userRoundImage = [[UIImageView alloc] initWithFrame:sizeUserImage];
    [userRoundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user%@", [UserDataSingleton sharedSingleton].Sufix]]];
    [self addSubview:userRoundImage];
    
    CGRect sizeUserNameLabel;
    sizeUserNameLabel.origin.x = userImageView.frame.origin.x + userImageView.frame.size.width + space;
    sizeUserNameLabel.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height / 4;
//    sizeUserNameLabel.size.height = offerNameLabel.frame.size.height;
    sizeUserNameLabel.size.height = userImageView.frame.size.height / 4;
    sizeUserNameLabel.size.width = selfFrame.size.width - sizeUserNameLabel.origin.x - sizeUserNameLabel.size.width - space;
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:sizeUserNameLabel];
    [userNameLabel setText:userName];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [userNameLabel setFont:[FONT regularFontWithSize:11]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [userNameLabel setFont:[FONT regularFontWithSize:19]];
    }
//    [userNameLabel setFont:textFont];
    [self addSubview:userNameLabel];
    
    CGRect sizePriceLabel = userNameLabel.frame;
    sizePriceLabel.origin.y += sizePriceLabel.size.height;
    
    NSRange range = [cost rangeOfString:@","];
    NSString *perHour;
    if (range.length != 0) {
        perHour = [cost substringToIndex:range.location];
    } else {
        perHour = cost;
    }
    NSMutableAttributedString *costString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", costUnit, perHour]];
    int rang = [perHour rangeOfString:@"per"].location;
    [costString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:221.0f/255.0f green:129.0f/255.0f blue:14.0f/255.0f alpha:1.0f] range:NSMakeRange(0, costUnit.length + rang)];
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:sizePriceLabel];
//    [priceLabel setText:cost];
    [priceLabel setAttributedText:costString];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [priceLabel setFont:[FONT regularFontWithSize:12]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [priceLabel setFont:[FONT regularFontWithSize:21]];
    }
//    [priceLabel setFont:textFont];
    [self addSubview:priceLabel];
    
    CGRect sizeSeparatorView;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeSeparatorView.size.height = 1;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeSeparatorView.size.height = 2;
    }
    sizeSeparatorView.size.width = self.frame.size.width - offerImageView.frame.origin.x * 2;
    sizeSeparatorView.origin.x = offerImageView.frame.origin.x;
    sizeSeparatorView.origin.y = self.frame.size.height - sizeSeparatorView.size.height;
    
    UIView *separatorView = [[UIView alloc] initWithFrame:sizeSeparatorView];
    [separatorView setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:separatorView];
}

/*- (void)getImage:(NSString *)imageString andType:(int)type {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:imageString];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
    if (theConnection) {
        imageData = [NSMutableData data];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"Connection failed");
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [UIImage imageWithData:imageData];
    [offerImageView setImage:image];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}*/

-(void)getImage:(NSString *)imageString andType:(int)type {
    UIImage *image = [[APICache sharedAPICache] objectForKey:imageString];
    if (image) {
        if (type == 0) {
            [offerImageView setImage:image];
        } else if (type == 1) {
            [userImageView setImage:image];
        }
    } else {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *fetchStreamOperation = [[NSBlockOperation alloc] init];
    [fetchStreamOperation addExecutionBlock:^{
        url = [NSURL URLWithString:imageString];
//        urlData = [NSData dataWithContentsOfURL:url];
        if (type == 0) {
            offerUrlData = [NSData dataWithContentsOfURL:url];
            if (offerUrlData) {
                [offerImageView setImage:[UIImage imageWithData:offerUrlData]];
                [[APICache sharedAPICache] setObject:[UIImage imageWithData:offerUrlData] forKey:imageString];
            } else {
                [offerImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"placeholder_offer%@", [UserDataSingleton sharedSingleton].Sufix]]];
            }
        } else if (type == 1) {
            userUrlData = [NSData dataWithContentsOfURL:url];
            if (userUrlData) {
                [userImageView setImage:[UIImage imageWithData:userUrlData]];
                [[APICache sharedAPICache] setObject:[UIImage imageWithData:userUrlData] forKey:imageString];
            } else {
                [userImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"placeholder_user%@", [UserDataSingleton sharedSingleton].Sufix]]];
            }
        }
    }];
    [queue addOperation:fetchStreamOperation];
    }
}


@end
