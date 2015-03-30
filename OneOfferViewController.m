//
//  OneOfferViewController.m
//  tryngo
//
//  Created by michail on 19/03/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "OneOfferViewController.h"
#import "UserDataSingleton.h"
#import "FONT.h"

@interface OneOfferViewController () {
    UIScrollView *scrollView;
    UIDevice *currentDevice;
    NSDictionary *offerDictionary;
    NSString *offerIndex;
    NSMutableArray *offerImagesArray;
    NSMutableArray *categoriesArray;
    NSMutableArray *subCategoriesArray;
    UIButton *leftArrowButton;
    UIButton *rightArrowButton;
    UIImageView *offerImageView;
    UIImageView *userImageView;
    NSURL  *url;
    NSData *offerUrlData;
    NSData *userUrlData;
}

@end

@implementation OneOfferViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithIndex:(NSString *)_index
{
    self = [super init];
    if (self) {
        // Custom initialization
        offerIndex = _index;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    offerImagesArray = [[NSMutableArray alloc] init];
    currentDevice = [UIDevice currentDevice];
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    categoriesArray = [[NSMutableArray alloc] init];
    subCategoriesArray =[[NSMutableArray alloc] init];
    [self.view addSubview:scrollView];
    [self getRequest];
//    [self create];
}

-(void)getRequest {
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:
                                         CGRectMake((self.view.frame.size.width - 30)/2,
                                                    (self.view.frame.size.height - 30)/2,
                                                    30, 30)];
    [activity setColor:[UIColor blackColor]];
    [self.view addSubview:activity];
    [activity startAnimating];
    NSString *requestString = [NSString stringWithFormat:@"https://www.tryngo.ch/api/getObject?id=%@", offerIndex];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:requestString]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30.0f];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if([data length] > 0 && error == nil) {
             offerDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error:nil];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self create];
                 [activity stopAnimating];
             });
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *alertView = [[UIAlertView alloc]
                                       initWithTitle:@"Error:"
                                       message:@"Error rerquest to server"
                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alertView show];
                 [activity stopAnimating];
             });
         }
     }];
}

-(void)getCategories {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@""]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30.0f];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if([data length] > 0 && error == nil) {
             offerDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:nil];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self create];
             });
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"Error:"
                                           message:@"Error rerquest to server"
                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alertView show];
             });
         }
     }];

}

-(void)create {
    UIFont *labelFont;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        labelFont = [FONT regularFontWithSize:24];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        labelFont = [FONT regularFontWithSize:42];
    }
    NSString *offerName = [offerDictionary objectForKey:@"title"];
    CGSize sizeString = [offerName sizeWithAttributes:@{NSFontAttributeName: labelFont}];
    CGRect sizeOfferNameLabel;
    sizeOfferNameLabel.size.height = sizeString.height;
    sizeOfferNameLabel.size.width = sizeString.width;
    sizeOfferNameLabel.origin.x = (self.view.frame.size.width - sizeOfferNameLabel.size.width) / 2;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeOfferNameLabel.origin.y = 50;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeOfferNameLabel.origin.y = 90;
    }
    
    UILabel *offerNameLabel = [[UILabel alloc] initWithFrame:sizeOfferNameLabel];
    [offerNameLabel setText:offerName];
    [offerNameLabel setFont:labelFont];
    [scrollView addSubview:offerNameLabel];
    
    UIImage *elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_big_offer%@", [UserDataSingleton sharedSingleton].Sufix]];
    
    NSString *imagesString = [offerDictionary objectForKey:@"images"];
    NSRange range;
    while (imagesString) {
        range = [imagesString rangeOfString:@","];
        if (range.length == 0) {
            [offerImagesArray addObject:imagesString];
            imagesString = nil;
        } else {
            NSString *currentString = [imagesString substringToIndex:range.location];
            [offerImagesArray addObject:currentString];
            imagesString = [imagesString substringFromIndex:(range.location + 1)];
        }
    }
    NSLog(@"images = %@", offerImagesArray);
    CGRect sizeOfferImageView;
    sizeOfferImageView.size.width = elementImage.size.width / 2;
    sizeOfferImageView.size.height = elementImage.size.height / 2;
    sizeOfferImageView.origin.x = (self.view.frame.size.width - sizeOfferImageView.size.width) / 2;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeOfferImageView.origin.y = offerNameLabel.frame.origin.y + offerNameLabel.frame.size.height + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeOfferImageView.origin.y = offerNameLabel.frame.origin.y + offerNameLabel.frame.size.height + 10;
    }
    
    offerImageView = [[UIImageView alloc] initWithFrame:sizeOfferImageView];
    NSString *offerUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].offerImagePrefix, offerIndex, [offerImagesArray objectAtIndex:0]];
/*    NSURL *offerUrlImage = [NSURL URLWithString:offerUrlString];
    NSData *offerDataImage = [NSData dataWithContentsOfURL:offerUrlImage];
    UIImage *offerImageFromUrl;
    if (offerDataImage) {
        offerImageFromUrl = [UIImage imageWithData:offerDataImage];
    } else {
        offerImageFromUrl = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_offer%@", [UserDataSingleton sharedSingleton].Sufix]];
//        [offerImageView setContentMode:UIViewContentModeCenter];
//        [offerImageView setContentMode:UIViewContentModeScaleAspectFit];
    }*/
    [offerImageView setContentMode:UIViewContentModeCenter];
    [offerImageView setContentMode:UIViewContentModeScaleAspectFit];
//    [offerImageView setImage:offerImageFromUrl];
    [self getImage:offerUrlString andType:0];
    [scrollView addSubview:offerImageView];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_arrow_left%@", [UserDataSingleton sharedSingleton].Sufix]];
    int countImage = 0;
    @try {
        countImage = [offerImagesArray count];
    } @catch (NSException *e) {
        countImage = 0;
    }
    CGRect sizeArrow;
    sizeArrow.size.width = elementImage.size.width / 2;
    sizeArrow.size.height = elementImage.size.height / 2;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeArrow.origin.x = offerImageView.frame.origin.x;
        sizeArrow.origin.y = offerImageView.frame.origin.y - sizeArrow.size.height - 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeArrow.origin.x = (offerImageView.frame.origin.x - sizeArrow.size.width) / 2;
        sizeArrow.origin.y = offerImageView.frame.origin.y - sizeArrow.size.height;
    }
    
    leftArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftArrowButton setFrame:sizeArrow];
    [leftArrowButton setImage:elementImage forState:UIControlStateNormal];
    [leftArrowButton setTag:-1];
    if (countImage > 1) {
        [leftArrowButton addTarget:self action:@selector(pressArrowButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [scrollView addSubview:leftArrowButton];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeArrow.origin.x += offerImageView.frame.size.width - sizeArrow.size.width;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeArrow.origin.x += offerImageView.frame.origin.x + offerImageView.frame.size.width;
    }
    
    rightArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightArrowButton setFrame:sizeArrow];
    if (countImage == 1) {
        [rightArrowButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_arrow_right%@", [UserDataSingleton sharedSingleton].Sufix]] forState:UIControlStateNormal];
    } else {
        [rightArrowButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_arrow_right_hover%@", [UserDataSingleton sharedSingleton].Sufix]] forState:UIControlStateNormal];
    }
    [rightArrowButton setTag:1];
    if (countImage > 1) {
        [rightArrowButton addTarget:self action:@selector(pressArrowButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [scrollView addSubview:rightArrowButton];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        labelFont = [FONT regularFontWithSize:15];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        labelFont = [FONT regularFontWithSize:30];
    }
    
    NSString *offerDescription = [offerDictionary objectForKey:@"description"];
    CGRect sizeOfferDescriptionLabel = [offerDescription boundingRectWithSize:CGSizeMake(offerImageView.frame.size.width, 1000)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:labelFont}
                                                                   context:nil];
    sizeOfferDescriptionLabel.size.width = offerImageView.frame.size.width;
    sizeOfferDescriptionLabel.origin.x = offerImageView.frame.origin.x;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeOfferDescriptionLabel.origin.y = offerImageView.frame.origin.y + offerImageView.frame.size.height + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeOfferDescriptionLabel.origin.y = offerImageView.frame.origin.y + offerImageView.frame.size.height + 10;
    }
    
    UILabel *offerDescriptionLabel = [[UILabel alloc] initWithFrame:sizeOfferDescriptionLabel];
    [offerDescriptionLabel setText:offerDescription];
    [offerDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [offerDescriptionLabel setFont:labelFont];
    [offerDescriptionLabel setNumberOfLines:0];
    [offerDescriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [scrollView addSubview:offerDescriptionLabel];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        labelFont = [FONT regularFontWithSize:14];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        labelFont = [FONT regularFontWithSize:26];
    }
    NSString *userName = [offerDictionary objectForKey:@"username"];
    sizeString = [userName sizeWithAttributes:@{NSFontAttributeName: labelFont}];
    
    CGRect sizeUserNameLabel;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeUserNameLabel.origin.x = 15;
        sizeUserNameLabel.origin.y = offerDescriptionLabel.frame.origin.y + offerDescriptionLabel.frame.size.height + 20;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeUserNameLabel.origin.x = 30;
        sizeUserNameLabel.origin.y = offerDescriptionLabel.frame.origin.y + offerDescriptionLabel.frame.size.height + 30;
    }
    sizeUserNameLabel.size.height = sizeString.height;
    sizeUserNameLabel.size.width = (self.view.frame.size.width - sizeUserNameLabel.origin.x * 2) / 2;
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:sizeUserNameLabel];
    [userNameLabel setText:userName];
    [userNameLabel setFont:labelFont];
    [scrollView addSubview:userNameLabel];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_user%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeUserImageView;
    sizeUserImageView.origin.x = userNameLabel.frame.origin.x;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeUserImageView.origin.y = userNameLabel.frame.origin.y + userNameLabel.frame.size.height + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeUserImageView.origin.y = userNameLabel.frame.origin.y + userNameLabel.frame.size.height + 10;
    }
    sizeUserImageView.size.height = elementImage.size.height - 20;
    sizeUserImageView.size.width = elementImage.size.width - 20;
    
    userImageView = [[UIImageView alloc] initWithFrame:sizeUserImageView];
    NSString *userUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].userImagePrefix, [offerDictionary objectForKey:@"user_id"], [offerDictionary objectForKey:@"user_photo"]];
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
    [scrollView addSubview:userImageView];
    
    UIImageView *userRoundImage = [[UIImageView alloc] initWithFrame:sizeUserImageView];
    [userRoundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user%@", [UserDataSingleton sharedSingleton].Sufix]]];
    [scrollView addSubview:userRoundImage];
    
    NSMutableArray *costStringArray = [[NSMutableArray alloc] init];
    NSString *costString = [offerDictionary objectForKey:@"cost"];
    while (costString) {
        range = [costString rangeOfString:@","];
        if (range.length == 0) {
            [costStringArray addObject:costString];
            costString = nil;
        } else {
            NSString *currentString = [costString substringToIndex:range.location];
            [costStringArray addObject:currentString];
            costString = [costString substringFromIndex:(range.location + 1)];
        }
    }
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        labelFont = [FONT regularFontWithSize:13];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        labelFont = [FONT regularFontWithSize:24];
    }
    CGRect sizeCostLabel;
    sizeCostLabel.origin.x = userImageView.frame.origin.x * 2 + userImageView.frame.size.width;
    sizeCostLabel.origin.y = userImageView.frame.origin.y;
    sizeCostLabel.size.height = userImageView.frame.size.height / 4;
    sizeCostLabel.size.width = self.view.frame.size.width - sizeCostLabel.origin.x - userImageView.frame.origin.x;
   
    int countCost = 0;
    @try {
        countCost = [costStringArray count];
    } @catch (NSException *e) {
        countCost = 0;
    }
    NSString *costUnit = [offerDictionary objectForKey:@"cost_unit"];
    int rang;
    for (int i = 0; i < countCost; i++) {
        NSString *perHour = [costStringArray objectAtIndex:i];
        NSMutableAttributedString *costStringAtt = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", costUnit, perHour]];
        rang = [perHour rangeOfString:@"per"].location;
        [costStringAtt addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:221.0f/255.0f green:129.0f/255.0f blue:14.0f/255.0f alpha:1.0f] range:NSMakeRange(0, costUnit.length + rang)];
        
        
        UILabel *costLabel = [[UILabel alloc] initWithFrame:sizeCostLabel];
        [costLabel setAttributedText:costStringAtt];
        [costLabel setFont:labelFont];
        [scrollView addSubview:costLabel];
        sizeCostLabel.origin.y += sizeCostLabel.size.height;
    }
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        labelFont = [FONT regularFontWithSize:15];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        labelFont = [FONT regularFontWithSize:29];
    }
    NSString *availableString = @"AVAILABLE AT:";
    sizeString = [availableString sizeWithAttributes:@{NSFontAttributeName: labelFont}];
    CGRect sizeAvailableLabel;
    sizeAvailableLabel.origin.x = userImageView.frame.origin.x;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeAvailableLabel.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height + 20;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeAvailableLabel.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height + 30;
    }
    sizeAvailableLabel.size.height = sizeString.height;
    sizeAvailableLabel.size.width = self.view.frame.size.width - sizeAvailableLabel.origin.x * 2;
    
    UILabel *availableLabel = [[UILabel alloc] initWithFrame:sizeAvailableLabel];
    [availableLabel setText:availableString];
    [availableLabel setFont:labelFont];
    [scrollView addSubview:availableLabel];

    CGRect sizeDaysLabel = availableLabel.frame;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeDaysLabel.origin.y = availableLabel.frame.origin.y + availableLabel.frame.size.height + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeDaysLabel.origin.y = availableLabel.frame.origin.y + availableLabel.frame.size.height + 10;
    }
    NSString *daysIndexString = [offerDictionary objectForKey:@"available_days"];
    NSMutableString *daysString = [[NSMutableString alloc] init];
    NSString *symbol;
    for (int i = 0; i < daysIndexString.length; i++) {
        symbol = [daysIndexString substringWithRange:NSMakeRange(i, 1)];
        if ([symbol isEqualToString:@","]) {
            [daysString insertString:@", " atIndex:daysString.length];
        } else if ([symbol isEqualToString:@"1"]) {
            [daysString insertString:@"Mon" atIndex:daysString.length];
        } else if ([symbol isEqualToString:@"2"]) {
            [daysString insertString:@"Tue" atIndex:daysString.length];
        } else if ([symbol isEqualToString:@"3"]) {
            [daysString insertString:@"Wed" atIndex:daysString.length];
        } else if ([symbol isEqualToString:@"4"]) {
            [daysString insertString:@"Thu" atIndex:daysString.length];
        } else if ([symbol isEqualToString:@"5"]) {
            [daysString insertString:@"Fri" atIndex:daysString.length];
        } else if ([symbol isEqualToString:@"6"]) {
            [daysString insertString:@"Sat" atIndex:daysString.length];
        } else if ([symbol isEqualToString:@"7"]) {
            [daysString insertString:@"Sun" atIndex:daysString.length];
        }
    }
    UILabel *daysLabel = [[UILabel alloc] initWithFrame:sizeDaysLabel];
    [daysLabel setText:daysString];
    [daysLabel setFont:labelFont];
    [scrollView addSubview:daysLabel];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        labelFont = [FONT boldFontWithSize:15];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        labelFont = [FONT boldFontWithSize:31];
    }
    
    CGRect sizeButtons;
    sizeButtons.origin.x = daysLabel.frame.origin.x;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeButtons.origin.y = daysLabel.frame.origin.y + daysLabel.frame.size.height + 20;
        sizeButtons.size.height = [@"Ag" sizeWithAttributes:@{NSFontAttributeName:labelFont}].height + 20;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeButtons.origin.y = daysLabel.frame.origin.y + daysLabel.frame.size.height + 30;
        sizeButtons.size.height = [@"Ag" sizeWithAttributes:@{NSFontAttributeName:labelFont}].height + 40;
    }
//    sizeButtons.size.height = daysLabel.frame.size.height * 2;
    sizeButtons.size.width = (self.view.frame.size.width - sizeButtons.origin.x * 3) / 2;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setFrame:sizeButtons];
    [backButton setBackgroundColor:[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f]];
    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:labelFont];
    [backButton.layer setCornerRadius:4];
    [backButton.layer setShadowColor:[UIColor colorWithRed:180.0f/255.0f green:180.0f/255.0f blue:180.0f/255.0f alpha:1.0f].CGColor];
    [backButton.layer setShadowOffset:CGSizeMake(0, 4)];
    [backButton.layer setShadowOpacity:1.0f];
    backButton.layer.masksToBounds = NO;
    [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:backButton];
    
    sizeButtons.origin.x += sizeButtons.origin.x + sizeButtons.size.width;
    
    UIButton *bookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bookButton setFrame:sizeButtons];
    [bookButton setBackgroundColor:[UIColor colorWithRed:77.0f/255.0f green:178.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
    [bookButton setTitle:@"BOOK" forState:UIControlStateNormal];
    [bookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bookButton.titleLabel setFont:labelFont];
    [backButton.layer setCornerRadius:4];
    [bookButton.layer setShadowColor:[UIColor colorWithRed:52.0f/255.0f green:147.0f/255.0f blue:202.0f/255.0f alpha:1.0f].CGColor];
    [bookButton.layer setShadowOffset:CGSizeMake(0, 4)];
    [bookButton.layer setShadowOpacity:1.0f];
    bookButton.layer.masksToBounds = NO;
    [bookButton addTarget:self action:@selector(pressBookButton) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:bookButton];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, bookButton.frame.origin.y + bookButton.frame.size.height + 20)];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, bookButton.frame.origin.y + bookButton.frame.size.height + 30)];
    }
}

-(void)getImage:(NSString *)imageString andType:(int)type {
        if (type == 0) {
     offerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_load_offer%@", [UserDataSingleton sharedSingleton].Sufix]];
     } else if (type == 1) {
     userImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_user%@", [UserDataSingleton sharedSingleton].Sufix]];
     }

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
//            urlData = [NSData dataWithContentsOfURL:url];
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

-(void)pressArrowButton:(UIButton *)button {
    if (button.tag == leftArrowButton.tag) {
        if (button.tag == 0) {
            [leftArrowButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_arrow_left%@", [UserDataSingleton sharedSingleton].Sufix]] forState:UIControlStateNormal];
            [leftArrowButton setTag:-1];
            [rightArrowButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_arrow_right_hover%@", [UserDataSingleton sharedSingleton].Sufix]] forState:UIControlStateNormal];
            [rightArrowButton setTag:1];
            NSString *offerUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].offerImagePrefix, offerIndex, [offerImagesArray objectAtIndex:(button.tag + 1)]];
            [self getImage:offerUrlString andType:0];
        } else if (button.tag > 0) {
            [leftArrowButton setTag:(button.tag - 1)];
            [rightArrowButton setTag:(button.tag + 1)];
            NSString *offerUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].offerImagePrefix, offerIndex, [offerImagesArray objectAtIndex:(button.tag + 1)]];
            [self getImage:offerUrlString andType:0];
        }
    } else if (button.tag == rightArrowButton.tag) {
        if (button.tag == offerImagesArray.count - 1) {
            [leftArrowButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_arrow_left_hover%@", [UserDataSingleton sharedSingleton].Sufix]] forState:UIControlStateNormal];
            [leftArrowButton setTag:(offerImagesArray.count - 2)];
            [rightArrowButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_arrow_right%@", [UserDataSingleton sharedSingleton].Sufix]] forState:UIControlStateNormal];
            [rightArrowButton setTag:offerImagesArray.count];
            NSString *offerUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].offerImagePrefix, offerIndex, [offerImagesArray objectAtIndex:(button.tag - 1)]];
            [self getImage:offerUrlString andType:0];
        } else if (button.tag < offerImagesArray.count) {
            [leftArrowButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_arrow_left_hover%@", [UserDataSingleton sharedSingleton].Sufix]] forState:UIControlStateNormal];
            [leftArrowButton setTag:(button.tag - 1)];
            [rightArrowButton setTag:(button.tag + 1)];
            NSString *offerUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].offerImagePrefix, offerIndex, [offerImagesArray objectAtIndex:(button.tag - 1)]];
            [self getImage:offerUrlString andType:0];
        }
    }
}

-(void)pressBackButton {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)pressBookButton {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [offerDictionary objectForKey:@"url"]]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
