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
#import "OfferImageView.h"

@interface OneOfferViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, OfferImageViewDelegate> {
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
    UIButton *offerImageButton;
    UIImageView *userImageView;
    NSURL  *url;
    NSData *offerUrlData;
    NSData *userUrlData;
    UICollectionView *offerCollectionView;
    OfferImageView *bigOfferImageView;
    UIActivityIndicatorView *offerActivity;
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
//    scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
//    [self.view addSubview:scrollView];
    categoriesArray = [[NSMutableArray alloc] init];
    subCategoriesArray =[[NSMutableArray alloc] init];
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
    CGRect sizeTitleView;
    sizeTitleView.origin.x = 0;
    sizeTitleView.origin.y = 20;
    sizeTitleView.size.width = self.view.frame.size.width;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeTitleView.size.height = 50;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeTitleView.size.height = 80;
    }
    UIView *titleView = [[UIView alloc] initWithFrame:sizeTitleView];
    [titleView setBackgroundColor:[UIColor colorWithRed:77.0f/255.0f green:178.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
    [self.view addSubview:titleView];
    
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
//        sizeButtons.size.height = [@"Ag" sizeWithAttributes:@{NSFontAttributeName:buttonFont}].height + 10;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeButtons.origin.x = 40;
//        sizeButtons.size.height = [@"Ag" sizeWithAttributes:@{NSFontAttributeName:buttonFont}].height + 20;
    }
    //    sizeButtons.size.height = daysLabel.frame.size.height * 2;
//    sizeButtons.size.width = (self.view.frame.size.width - sizeButtons.origin.x * 3) / 2;
    sizeButtons.size.width = elementImage.size.width / 2;
    sizeButtons.size.height = elementImage.size.height / 2;
    sizeButtons.origin.y = (titleView.frame.size.height - sizeButtons.size.height) / 2;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setFrame:sizeButtons];
//    [backButton setBackgroundColor:[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f]];
    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:buttonFont];
//    [backButton.layer setCornerRadius:4];
//    [backButton.layer setShadowColor:[UIColor colorWithRed:180.0f/255.0f green:180.0f/255.0f blue:180.0f/255.0f alpha:1.0f].CGColor];
//    [backButton.layer setShadowOffset:CGSizeMake(0, 4)];
//    [backButton.layer setShadowOpacity:1.0f];
//    backButton.layer.masksToBounds = NO;
    [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:elementImage forState:UIControlStateNormal];
    [titleView addSubview:backButton];
    
//    sizeButtons.origin.x += sizeButtons.origin.x + sizeButtons.size.width;
    sizeButtons.origin.x = titleView.frame.size.width - backButton.frame.origin.x - sizeButtons.size.width;
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"button_book%@", [UserDataSingleton sharedSingleton].Sufix]];
    
    UIButton *bookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bookButton setFrame:sizeButtons];
//    [bookButton setBackgroundColor:[UIColor colorWithRed:77.0f/255.0f green:178.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
    [bookButton setTitle:@"BOOK" forState:UIControlStateNormal];
    [bookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bookButton.titleLabel setFont:buttonFont];
//    [backButton.layer setCornerRadius:4];
//    [bookButton.layer setShadowColor:[UIColor colorWithRed:52.0f/255.0f green:147.0f/255.0f blue:202.0f/255.0f alpha:1.0f].CGColor];
//    [bookButton.layer setShadowOffset:CGSizeMake(0, 4)];
//    [bookButton.layer setShadowOpacity:1.0f];
//    bookButton.layer.masksToBounds = NO;
    [bookButton addTarget:self action:@selector(pressBookButton) forControlEvents:UIControlEventTouchUpInside];
    [bookButton setBackgroundImage:elementImage forState:UIControlStateNormal];
    [titleView addSubview:bookButton];
    
    CGRect sizeScrollView = self.view.frame;
    sizeScrollView.origin.y = titleView.frame.origin.y + titleView.frame.size.height;
    sizeScrollView.size.height -= sizeScrollView.origin.y;
    scrollView = [[UIScrollView alloc] initWithFrame:sizeScrollView];
    [self.view addSubview:scrollView];
    
/*    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"top_image%@", [UserDataSingleton sharedSingleton].Sufix]];
    
    CGRect sizeTopImageView;
    sizeTopImageView.size.height = elementImage.size.height / 2;
    sizeTopImageView.size.width = elementImage.size.width / 2;//scrollView.frame.size.width;
    sizeTopImageView.origin.x = 0;
    sizeTopImageView.origin.y = -sizeTopImageView.size.height;
    
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:sizeTopImageView];
    [topImageView setImage:elementImage];
    [scrollView addSubview:topImageView];*/
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        buttonFont = [FONT regularFontWithSize:24];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonFont = [FONT regularFontWithSize:42];
    }
    
    NSString *offerName = [self encode:[offerDictionary objectForKey:@"title"]];
    CGSize sizeString = [offerName sizeWithAttributes:@{NSFontAttributeName: buttonFont}];
    CGRect sizeOfferNameLabel;
    sizeOfferNameLabel.size.height = sizeString.height;
    sizeOfferNameLabel.size.width = sizeString.width;
    sizeOfferNameLabel.origin.x = (self.view.frame.size.width - sizeOfferNameLabel.size.width) / 2;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeOfferNameLabel.origin.y = 10;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeOfferNameLabel.origin.y = 20;
    }
    
    UILabel *offerNameLabel = [[UILabel alloc] initWithFrame:sizeOfferNameLabel];
    [offerNameLabel setText:offerName];
    [offerNameLabel setFont:buttonFont];
    [scrollView addSubview:offerNameLabel];
    
    NSString *imagesString = [offerDictionary objectForKey:@"images"];
    NSRange range;
    while (imagesString) {
        range = [imagesString rangeOfString:@","];
        if (range.length == 0) {
/*            if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                [offerImagesArray addObject:[NSString stringWithFormat:@"%@/%@/%@&w=50&h=50&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, imagesString]];
            }
            if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                [offerImagesArray addObject:[NSString stringWithFormat:@"%@/%@/%@&w=100&h=100&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, imagesString]];
            }*/
            [offerImagesArray addObject:imagesString];
            imagesString = nil;
        } else {
//            NSString *currentString = [imagesString substringToIndex:range.location];
            NSString *currentString = [imagesString substringToIndex:range.location];
 /*           if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                currentString = [NSString stringWithFormat:@"%@/%@/%@&w=50&h=50&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [imagesString substringToIndex:range.location]];
            }
            if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                currentString = [NSString stringWithFormat:@"%@/%@/%@&w=100&h=100&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [imagesString substringToIndex:range.location]];
            }*/
            [offerImagesArray addObject:currentString];
            imagesString = [imagesString substringFromIndex:(range.location + 1)];
        }
    }
    
    CGRect sizeOfferImageView;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeOfferImageView.size.width = scrollView.frame.size.width / 2 - 20;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeOfferImageView.size.width = scrollView.frame.size.width / 2 - 40;
    }
    sizeOfferImageView.size.height = sizeOfferImageView.size.width;
//    sizeOfferImageView.origin.x = (self.view.frame.size.width - sizeOfferImageView.size.width) / 2;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeOfferImageView.origin.x = 10;
        sizeOfferImageView.origin.y = offerNameLabel.frame.origin.y + offerNameLabel.frame.size.height + 10;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeOfferImageView.origin.x = 20;
        sizeOfferImageView.origin.y = offerNameLabel.frame.origin.y + offerNameLabel.frame.size.height + 20;
    }
    
    offerImageView = [[UIImageView alloc] initWithFrame:sizeOfferImageView];
//    NSString *offerUrlString = [NSString stringWithFormat:@"%@%@/%@", [UserDataSingleton sharedSingleton].offerImagePrefix, offerIndex, [offerImagesArray objectAtIndex:0]];
    NSString *offerUrlString;// = [offerImagesArray objectAtIndex:0];//[NSString stringWithFormat:@"%@/%@/%@&w=%f&h=%f&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [offerImagesArray objectAtIndex:0], sizeOfferImageView.size.width, sizeOfferImageView.size.height];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        offerUrlString = [NSString stringWithFormat:@"%@/%@/%@&w=100&h=100&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [offerImagesArray objectAtIndex:0]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        offerUrlString = [NSString stringWithFormat:@"%@/%@/%@&w=200&h=200&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [offerImagesArray objectAtIndex:0]];
    }
    [offerImageView setContentMode:UIViewContentModeCenter];
    [offerImageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self getImage:offerUrlString andType:0];
//    [offerImageView setImage:[[APICache sharedAPICache] objectForKey:offerUrlString]];
    CGRect sizeActivity;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeActivity.size.height = sizeActivity.size.width = 20;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeActivity.size.height = sizeActivity.size.width = 40;
    }
    sizeActivity.origin.x = offerImageView.frame.origin.x + (offerImageView.frame.size.width - sizeActivity.size.width) / 2;
    sizeActivity.origin.y = offerImageView.frame.origin.y + (offerImageView.frame.size.height - sizeActivity.size.height) / 2;
    offerActivity = [[UIActivityIndicatorView alloc] initWithFrame:sizeActivity];
    [offerActivity setColor:[UIColor blackColor]];
    [scrollView addSubview:offerActivity];
    [self loadBigOfferImage:offerUrlString];
/*    [offerActivity startAnimating];
    UIImage *offerImage = [[APICache sharedAPICache] objectForKey:offerUrlString];
    if (offerImage) {
        [offerImageView setImage:offerImage];
        [offerActivity stopAnimating];
    } else {
        //        [self getImage:offerUrlString];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *postImage = [UIImage  imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:offerUrlString]]];
            
            if (postImage) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[APICache sharedAPICache] setObject:postImage forKey:offerUrlString];
                    [offerImageView setImage:postImage];
                    [offerActivity stopAnimating];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[APICache sharedAPICache] setObject:elementImage forKey:offerUrlString];
                    [offerImageView setImage:elementImage];
                    [offerActivity stopAnimating];
                });
            }
        });
    }*/

    [scrollView addSubview:offerImageView];
    
    offerImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [offerImageButton setFrame:sizeOfferImageView];
    [offerImageButton addTarget:self action:@selector(offerImageTap) forControlEvents:UIControlEventTouchUpInside];
    [offerImageButton setTag:0];
    [scrollView addSubview:offerImageButton];
    
    CGRect sizeCollectionView = sizeOfferImageView;
    sizeCollectionView.origin.y += sizeOfferImageView.size.height + 5;
    sizeCollectionView.size.height /= 3;
    UICollectionViewFlowLayout *layot = [[UICollectionViewFlowLayout alloc] init];
    [layot setScrollDirection:UICollectionViewScrollDirectionHorizontal];
/*    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *fetchStreamOperation = [[NSBlockOperation alloc] init];
    [fetchStreamOperation addExecutionBlock:^{*/
        offerCollectionView = [[UICollectionView alloc] initWithFrame:sizeCollectionView collectionViewLayout:layot];
        [offerCollectionView setBackgroundColor:[UIColor clearColor]];
        offerCollectionView.delegate = self;
        offerCollectionView.dataSource = self;
        [offerCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [scrollView addSubview:offerCollectionView];
/*    }];
    [queue addOperation:fetchStreamOperation];*/
    
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
        buttonFont = [FONT regularFontWithSize:13];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonFont = [FONT regularFontWithSize:24];
    }
    CGRect sizeCostLabel;
    sizeCostLabel.origin.x = offerImageView.frame.origin.x * 2 + offerImageView.frame.size.width;
    sizeCostLabel.origin.y = offerImageView.frame.origin.y;
//    sizeCostLabel.size.height = offerImageView.frame.size.height / 4;
    sizeCostLabel.size.height = [offerName sizeWithAttributes:@{NSFontAttributeName: buttonFont}].height;
    sizeCostLabel.size.width = self.view.frame.size.width - sizeCostLabel.origin.x - offerImageView.frame.origin.x;
    
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
        [costLabel setFont:buttonFont];
        [scrollView addSubview:costLabel];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            sizeCostLabel.origin.y += sizeCostLabel.size.height + 5;
        }
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            sizeCostLabel.origin.y += sizeCostLabel.size.height + 10;
        }
    }

    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        buttonFont = [FONT regularFontWithSize:15];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonFont = [FONT regularFontWithSize:30];
    }
    
    float widthOfferDescription = scrollView.frame.size.width - offerImageView.frame.origin.x * 2;
    NSString *offerDescription = [self encode:[offerDictionary objectForKey:@"description"]];
    CGRect sizeOfferDescriptionLabel = [offerDescription boundingRectWithSize:CGSizeMake(widthOfferDescription, 1000)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName:buttonFont}
                                                                      context:nil];
    sizeOfferDescriptionLabel.size.width = widthOfferDescription;
    sizeOfferDescriptionLabel.origin.x = offerImageView.frame.origin.x;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeOfferDescriptionLabel.origin.y = sizeCollectionView.origin.y + sizeCollectionView.size.height + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeOfferDescriptionLabel.origin.y = sizeCollectionView.origin.y + sizeCollectionView.size.height + 10;
    }
    
    UILabel *offerDescriptionLabel = [[UILabel alloc] initWithFrame:sizeOfferDescriptionLabel];
    [offerDescriptionLabel setText:offerDescription];
//    [offerDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [offerDescriptionLabel setFont:buttonFont];
    [offerDescriptionLabel setNumberOfLines:0];
    [offerDescriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [scrollView addSubview:offerDescriptionLabel];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_user%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeUserImageView;
    sizeUserImageView.origin.x = offerDescriptionLabel.frame.origin.x;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeUserImageView.origin.y = offerDescriptionLabel.frame.origin.y + offerDescriptionLabel.frame.size.height + 10;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeUserImageView.origin.y = offerDescriptionLabel.frame.origin.y + offerDescriptionLabel.frame.size.height + 20;
    }
    sizeUserImageView.size.height = elementImage.size.height - 20;
    sizeUserImageView.size.width = elementImage.size.width - 20;
    
    userImageView = [[UIImageView alloc] initWithFrame:sizeUserImageView];
    [userImageView setContentMode:UIViewContentModeScaleToFill];
    NSString *userUrlString = [NSString stringWithFormat:@"%@%@/%@&w=100&h=100&q=100", [UserDataSingleton sharedSingleton].userImagePrefix, [offerDictionary objectForKey:@"user_id"], [offerDictionary objectForKey:@"user_photo"]];
//    [self getImage:userUrlString andType:1];
    [userImageView setImage:[[APICache sharedAPICache] objectForKey:userUrlString]];
    [scrollView addSubview:userImageView];
    
    UIImageView *userRoundImage = [[UIImageView alloc] initWithFrame:sizeUserImageView];
    [userRoundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"user%@", [UserDataSingleton sharedSingleton].Sufix]]];
    [scrollView addSubview:userRoundImage];

    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        buttonFont = [FONT regularFontWithSize:14];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonFont = [FONT regularFontWithSize:26];
    }
    NSString *userName = [self encode:[offerDictionary objectForKey:@"username"]];
    sizeString = [userName sizeWithAttributes:@{NSFontAttributeName: buttonFont}];
    
    CGRect sizeUserNameLabel;
    sizeUserNameLabel.origin.x = userImageView.frame.origin.x * 2 + userImageView.frame.size.width;
/*    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeUserNameLabel.origin.y = offerDescriptionLabel.frame.origin.y + offerDescriptionLabel.frame.size.height + 20;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeUserNameLabel.origin.y = offerDescriptionLabel.frame.origin.y + offerDescriptionLabel.frame.size.height + 30;
    }*/
    sizeUserNameLabel.size.height = sizeString.height;
//    sizeUserNameLabel.size.width = (self.view.frame.size.width - sizeUserNameLabel.origin.x * 2) / 2;
    sizeUserNameLabel.size.width = self.view.frame.size.width - sizeUserNameLabel.origin.x - userImageView.frame.origin.x;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeUserNameLabel.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height / 2 - sizeUserNameLabel.size.height - 2.5f;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeUserNameLabel.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height / 2 - sizeUserNameLabel.size.height - 5;
    }
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:sizeUserNameLabel];
    [userNameLabel setText:userName];
    [userNameLabel setFont:buttonFont];
    [scrollView addSubview:userNameLabel];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"pin%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeMapImageView;
    sizeMapImageView.size.width = elementImage.size.width / 2;
    sizeMapImageView.size.height = elementImage.size.height / 2;
    sizeMapImageView.origin.x = userNameLabel.frame.origin.x;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeMapImageView.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height / 2 + 2.5f;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeMapImageView.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height / 2 + 5;
    }
    
    UIImageView *mapImageView = [[UIImageView alloc] initWithFrame:sizeMapImageView];
    [mapImageView setImage:elementImage];
    [scrollView addSubview:mapImageView];
    
    CGRect sizePlaceLabel;
    sizePlaceLabel.origin.x = mapImageView.frame.origin.x + mapImageView.frame.size.width + userImageView.frame.origin.x;
    sizePlaceLabel.origin.y = mapImageView.frame.origin.y;
    sizePlaceLabel.size.height = mapImageView.frame.size.height;
    sizePlaceLabel.size.width = scrollView.frame.size.width - sizePlaceLabel.origin.x - userImageView.frame.origin.x;
    
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:sizePlaceLabel];
    [placeLabel setText:[self encode:[offerDictionary objectForKey:@"location"]]];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [placeLabel setFont:[FONT regularFontWithSize:14]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [placeLabel setFont:[FONT regularFontWithSize:24]];
    }
    //    [placeLabel setFont:textFont];
    [scrollView addSubview:placeLabel];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"clock%@", [UserDataSingleton sharedSingleton].Sufix]];
    
    CGRect sizeClockView;
    sizeClockView.size.height = elementImage.size.height / 2;
    sizeClockView.size.width = scrollView.frame.size.width;
    sizeClockView.origin.x = 0;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeClockView.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeClockView.origin.y = userImageView.frame.origin.y + userImageView.frame.size.height + 10;
    }
    
    UIView *clockView = [[UIView alloc] initWithFrame:sizeClockView];
    [scrollView addSubview:clockView];
    
    CGRect sizeClockImageView;
    sizeClockImageView.origin.x = sizeClockImageView.origin.y = 0;
    sizeClockImageView.size.height = sizeClockImageView.size.width = elementImage.size.width / 2;
    
    UIImageView *fromClockView = [[UIImageView alloc] initWithFrame:sizeClockImageView];
    [fromClockView setImage:elementImage];
    [clockView addSubview:fromClockView];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        buttonFont = [FONT regularFontWithSize:15];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonFont = [FONT regularFontWithSize:26];
    }
    
    CGRect sizeFromLabel;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeFromLabel.origin.x = fromClockView.frame.origin.x + fromClockView.frame.size.width + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeFromLabel.origin.x = fromClockView.frame.origin.x + fromClockView.frame.size.width + 10;
    }
    sizeFromLabel.origin.y = 0;
    sizeFromLabel.size.height = clockView.frame.size.height;
    sizeFromLabel.size.width = [@"From:" sizeWithAttributes:@{NSFontAttributeName: buttonFont}].width;
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:sizeFromLabel];
    [fromLabel setText:@"From:"];
    [fromLabel setFont:buttonFont];
    [clockView addSubview:fromLabel];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        buttonFont = [FONT boldFontWithSize:25];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonFont = [FONT boldFontWithSize:44];
    }
    
    NSString *fromString = [[offerDictionary objectForKey:@"object_event_starttime"] substringToIndex:5];
    CGRect sizeFromTimeLabel = fromLabel.frame;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeFromTimeLabel.origin.x = fromLabel.frame.origin.x + fromLabel.frame.size.width + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeFromTimeLabel.origin.x = fromLabel.frame.origin.x + fromLabel.frame.size.width + 10;
    }
    
    sizeFromTimeLabel.origin.y = 0;
    sizeFromTimeLabel.size.height = clockView.frame.size.height;
    sizeFromTimeLabel.size.width = [fromString sizeWithAttributes:@{NSFontAttributeName:buttonFont}].width;
    
    UILabel *fromTimeLabel = [[UILabel alloc] initWithFrame:sizeFromTimeLabel];
    [fromTimeLabel setText:fromString];
    [fromTimeLabel setFont:buttonFont];
    [clockView addSubview:fromTimeLabel];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeClockImageView.origin.x = fromTimeLabel.frame.origin.x + fromTimeLabel.frame.size.width + 10;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeClockImageView.origin.x = fromTimeLabel.frame.origin.x + fromTimeLabel.frame.size.width + 20;
    }

    UIImageView *upClockView = [[UIImageView alloc] initWithFrame:sizeClockImageView];
    [upClockView setImage:elementImage];
    [clockView addSubview:upClockView];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        buttonFont = [FONT regularFontWithSize:15];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonFont = [FONT regularFontWithSize:26];
    }
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeFromLabel.origin.x = upClockView.frame.origin.x + upClockView.frame.size.width + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeFromLabel.origin.x = upClockView.frame.origin.x + upClockView.frame.size.width + 10;
    }
    sizeFromLabel.size.width = [@"Up to:" sizeWithAttributes:@{NSFontAttributeName: buttonFont}].width;
    
    UILabel *upLabel = [[UILabel alloc] initWithFrame:sizeFromLabel];
    [upLabel setText:@"Up to:"];
    [upLabel setFont:buttonFont];
    [clockView addSubview:upLabel];
    
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        buttonFont = [FONT boldFontWithSize:25];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        buttonFont = [FONT boldFontWithSize:44];
    }
    
    NSString *upString = [[offerDictionary objectForKey:@"object_event_endtime"] substringToIndex:5];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeFromTimeLabel.origin.x = upLabel.frame.origin.x + upLabel.frame.size.width + 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeFromTimeLabel.origin.x = upLabel.frame.origin.x + upLabel.frame.size.width + 10;
    }
    
    sizeFromTimeLabel.size.width = [upString sizeWithAttributes:@{NSFontAttributeName:buttonFont}].width;
    
    UILabel *upTimeLabel = [[UILabel alloc] initWithFrame:sizeFromTimeLabel];
    [upTimeLabel setText:upString];
    [upTimeLabel setFont:buttonFont];
    [clockView addSubview:upTimeLabel];
    
    sizeClockView.size.width = upTimeLabel.frame.origin.x + upTimeLabel.frame.size.width;
    sizeClockView.origin.x = (scrollView .frame.size.width - sizeClockView.size.width) / 2;
    [clockView setFrame:sizeClockView];
    
    CGRect sizeDaysView;
    sizeDaysView.origin.x = 0;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeDaysView.origin.y = sizeClockView.origin.y + sizeClockView.size.height + 5;
        sizeDaysView.size.height = 40;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeDaysView.origin.y = sizeClockView.origin.y + sizeClockView.size.height + 10;
        sizeDaysView.size.height = 100;
    }
    sizeDaysView.size.width = scrollView.frame.size.width;
    
    UIView *daysView = [[UIView alloc] initWithFrame:sizeDaysView];
    [daysView setBackgroundColor:[UIColor colorWithRed:183.0f/255.0f green:183.0f/255.0f blue:183.0f/255.0f alpha:1.0f]];
    [scrollView addSubview:daysView];
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, daysView.frame.origin.y + daysView.frame.size.height)];
    
    NSString *daysIndexString = [offerDictionary objectForKey:@"available_days"];
    int space;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        space = 5;
        buttonFont = [FONT regularFontWithSize:18];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        space = 10;
        buttonFont = [FONT regularFontWithSize:37];
    }
    float widthDay = [@"Moni" sizeWithAttributes:@{NSFontAttributeName:buttonFont}].width;
    
    CGRect sizeDayLabel;
    sizeDayLabel.origin.x = (daysView.frame.size.width - widthDay * 7 - space * 6) / 2;
    sizeDayLabel.origin.y = 0;
    sizeDayLabel.size.height = daysView.frame.size.height;
    sizeDayLabel.size.width = widthDay;
    
    NSRange rangeDay = [daysIndexString rangeOfString:@"1"];
    UILabel *monDay = [[UILabel alloc] initWithFrame:sizeDayLabel];
    [monDay setText:@"Mon"];
    [monDay setTextAlignment:NSTextAlignmentCenter];
    if (rangeDay.length == 1) {
        [monDay setTextColor:[UIColor whiteColor]];
    } else {
        [monDay setTextColor:[UIColor blackColor]];
    }
    [monDay setFont:buttonFont];
    [daysView addSubview:monDay];
    
    sizeDayLabel.origin.x += sizeDayLabel.size.width + space;
    rangeDay = [daysIndexString rangeOfString:@"2"];
    UILabel *tueDay = [[UILabel alloc] initWithFrame:sizeDayLabel];
    [tueDay setText:@"Tue"];
    [tueDay setTextAlignment:NSTextAlignmentCenter];
    if (rangeDay.length == 1) {
        [tueDay setTextColor:[UIColor whiteColor]];
    } else {
        [tueDay setTextColor:[UIColor blackColor]];
    }
    [tueDay setFont:buttonFont];
    [daysView addSubview:tueDay];
    
    sizeDayLabel.origin.x += sizeDayLabel.size.width + space;
    rangeDay = [daysIndexString rangeOfString:@"3"];
    UILabel *wedDay = [[UILabel alloc] initWithFrame:sizeDayLabel];
    [wedDay setText:@"Wed"];
    [wedDay setTextAlignment:NSTextAlignmentCenter];
    if (rangeDay.length == 1) {
        [wedDay setTextColor:[UIColor whiteColor]];
    } else {
        [wedDay setTextColor:[UIColor blackColor]];
    }
    [wedDay setFont:buttonFont];
    [daysView addSubview:wedDay];
    
    sizeDayLabel.origin.x += sizeDayLabel.size.width + space;
    rangeDay = [daysIndexString rangeOfString:@"4"];
    UILabel *thuDay = [[UILabel alloc] initWithFrame:sizeDayLabel];
    [thuDay setText:@"Thu"];
    [thuDay setTextAlignment:NSTextAlignmentCenter];
    if (rangeDay.length == 1) {
        [thuDay setTextColor:[UIColor whiteColor]];
    } else {
        [thuDay setTextColor:[UIColor blackColor]];
    }
    [thuDay setFont:buttonFont];
    [daysView addSubview:thuDay];
    
    sizeDayLabel.origin.x += sizeDayLabel.size.width + space;
    rangeDay = [daysIndexString rangeOfString:@"5"];
    UILabel *friDay = [[UILabel alloc] initWithFrame:sizeDayLabel];
    [friDay setText:@"Fri"];
    [friDay setTextAlignment:NSTextAlignmentCenter];
    if (rangeDay.length == 1) {
        [friDay setTextColor:[UIColor whiteColor]];
    } else {
        [friDay setTextColor:[UIColor blackColor]];
    }
    [friDay setFont:buttonFont];
    [daysView addSubview:friDay];
    
    sizeDayLabel.origin.x += sizeDayLabel.size.width + space;
    rangeDay = [daysIndexString rangeOfString:@"6"];
    UILabel *satDay = [[UILabel alloc] initWithFrame:sizeDayLabel];
    [satDay setText:@"Sat"];
    [satDay setTextAlignment:NSTextAlignmentCenter];
    if (rangeDay.length == 1) {
        [satDay setTextColor:[UIColor whiteColor]];
    } else {
        [satDay setTextColor:[UIColor blackColor]];
    }
    [satDay setFont:buttonFont];
    [daysView addSubview:satDay];
    
    sizeDayLabel.origin.x += sizeDayLabel.size.width + space;
    rangeDay = [daysIndexString rangeOfString:@"7"];
    UILabel *sunDay = [[UILabel alloc] initWithFrame:sizeDayLabel];
    [sunDay setText:@"Sun"];
    [sunDay setTextAlignment:NSTextAlignmentCenter];
    if (rangeDay.length == 1) {
        [sunDay setTextColor:[UIColor whiteColor]];
    } else {
        [sunDay setTextColor:[UIColor blackColor]];
    }
    [sunDay setFont:buttonFont];
    [daysView addSubview:sunDay];

}

-(void)createOld {
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

-(void)getImage:(NSString *)imageString andView:(UIImageView *)imageView {
    UIImage *elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_offer%@", [UserDataSingleton sharedSingleton].Sufix]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *postImage = [UIImage  imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageString]]];
        if (postImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APICache sharedAPICache] setObject:postImage forKey:imageString];
                [imageView setImage:postImage];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APICache sharedAPICache] setObject:elementImage forKey:imageString];
                [imageView setImage:elementImage];
            });
        }
    });

/*    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_load_offer%@", [UserDataSingleton sharedSingleton].Sufix]];
    
    UIImage *image = [[APICache sharedAPICache] objectForKey:imageString];
    if (image) {
        [imageView setImage:image];
    } else {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSBlockOperation *fetchStreamOperation = [[NSBlockOperation alloc] init];
        [fetchStreamOperation addExecutionBlock:^{
            url = [NSURL URLWithString:imageString];
            //            urlData = [NSData dataWithContentsOfURL:url];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
                if (urlData) {
                    [imageView setImage:[UIImage imageWithData:urlData]];
                    [[APICache sharedAPICache] setObject:[UIImage imageWithData:urlData] forKey:imageString];
                } else {
                    [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"placeholder_offer%@", [UserDataSingleton sharedSingleton].Sufix]]];
                }
        }];
        [queue addOperation:fetchStreamOperation];
    }*/
}

-(void)loadBigOfferImage:(NSString *)offerUrlString {
    UIImage *elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"placeholder_offer%@", [UserDataSingleton sharedSingleton].Sufix]];
    [offerActivity startAnimating];
    UIImage *offerImage = [[APICache sharedAPICache] objectForKey:offerUrlString];
    if (offerImage) {
        [offerImageView setImage:offerImage];
        [offerActivity stopAnimating];
    } else {
        //        [self getImage:offerUrlString];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *postImage = [UIImage  imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:offerUrlString]]];
            
            if (postImage) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[APICache sharedAPICache] setObject:postImage forKey:offerUrlString];
                    [offerImageView setImage:postImage];
                    [offerActivity stopAnimating];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[APICache sharedAPICache] setObject:elementImage forKey:offerUrlString];
                    [offerImageView setImage:elementImage];
                    [offerActivity stopAnimating];
                });
            }
        });
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
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)pressBookButton {
    NSString *urlEncoded = [[NSString stringWithFormat:@"http://%@", [offerDictionary objectForKey:@"url"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlEncoded]];
    NSLog(@"book string = %@", [NSString stringWithFormat:@"http://%@", [offerDictionary objectForKey:@"url"]]);
    NSLog(@"book url = %@", [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [offerDictionary objectForKey:@"url"]]]);
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [offerDictionary objectForKey:@"url"]]]];
}

- (void)offerImageTap {
    NSLog(@"button.tag = %ld", (long)offerImageButton.tag);
    bigOfferImageView = [[OfferImageView alloc] initWithFrame:self.view.frame andImageIndex:offerIndex andImageName:[offerImagesArray objectAtIndex:offerImageButton.tag]];
    bigOfferImageView.delegate = self;
    [self.view addSubview:bigOfferImageView];
}

-(void)removeOfferImage {
    for (UIView *subview in [bigOfferImageView subviews]) {
        [subview removeFromSuperview];
    }
    [bigOfferImageView removeFromSuperview];
    bigOfferImageView = nil;
}

-(NSString *)encode:(NSString *)string {
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return offerImagesArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
/*//    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    OfferCollectionViewCell *offerCollectionViewCell = [cv dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [offerCollectionViewCell setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *offerCellImageView = [[UIImageView alloc] init];
    [offerCollectionViewCell setBackgroundColor:[UIColor clearColor]];
    [offerCollectionViewCell addSubview:offerCellImageView];
    [self getImage:[offerImagesArray objectAtIndex:indexPath.item] andView:offerCellImageView];
    return offerCollectionViewCell;*/
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *currentString;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        currentString = [NSString stringWithFormat:@"%@/%@/%@&w=50&h=50&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [offerImagesArray objectAtIndex:indexPath.item]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        currentString = [NSString stringWithFormat:@"%@/%@/%@&w=100&h=100&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [offerImagesArray objectAtIndex:indexPath.item]];
    }
    
    CGRect sizeImage = cell.frame;
    sizeImage.origin.x = sizeImage.origin.y = 0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:sizeImage];
//    [self getImage:[offerImagesArray objectAtIndex:indexPath.item] andView:imageView];
    [self getImage:currentString andView:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview:imageView];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    NSString *offerUrlString;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        offerUrlString = [NSString stringWithFormat:@"%@/%@/%@&w=100&h=100&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [offerImagesArray objectAtIndex:indexPath.item]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        offerUrlString = [NSString stringWithFormat:@"%@/%@/%@&w=200&h=200&q=100", [UserDataSingleton sharedSingleton].thumbImagePrefix, offerIndex, [offerImagesArray objectAtIndex:indexPath.item]];
    }
//    [offerImageView setImage:[[APICache sharedAPICache] objectForKey:key]];
//    [offerImageView setImage:[[APICache sharedAPICache] objectForKey:[offerImagesArray objectAtIndex:indexPath.item]]];
    [self loadBigOfferImage:offerUrlString];
    [offerImageButton setTag:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
/*    NSString *searchTerm = self.searches[indexPath.section]; FlickrPhoto *photo =
    self.searchResults[searchTerm][indexPath.row];
    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
    retval.height += 35; retval.width += 35; return retval;*/
    return CGSizeMake(offerCollectionView.frame.size.height, collectionView.frame.size.height);
}

/*- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}*/

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
