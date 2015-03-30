//
//  OfferViewController.m
//  tryngo
//
//  Created by michail on 13/03/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import "OfferViewController.h"
#import "OneOfferViewController.h"
#import "UserDataSingleton.h"

@interface OfferViewController () {
    CLLocationManager *locationManager;
    CLLocationCoordinate2D user_loc;
    UIDevice *currentDevice;
    UITableView *offerTableView;
    UIView *searchView;
    NSArray *offersArray;
    NSMutableArray *categoryArray;
    NSMutableArray *allSubCategoryArray;
    NSArray *subCategoryArray;
    UITextField *activeTextField;
    UITextField *locationText;
    UITextField *whatYouNeedText;
    UIButton *categoryButton;
    UIButton *subCategoryButton;
    NSString *latLocation;
    NSString *lngLocation;
    NSString *keyWord;
    NSString *cityName;
    UILabel *titleLabel;
    BOOL isLocation;
    CategoryPopover *popupView;
    NSString *indexCategory;
    NSString *indexSubCategory;
    UIButton *menuButton;
}
@end

@implementation OfferViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    keyWord = @"";
    cityName = @"";
    indexCategory = @"";
    indexSubCategory = @"";
    [self create];
    isLocation = false;
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self getUserLocation];
    categoryArray = [[NSMutableArray alloc] init];
    allSubCategoryArray = [[NSMutableArray alloc] init];
    subCategoryArray = [[NSArray alloc] init];
    [self getCategoryRequest];
//    [self getRequest];
}

-(void)getRequest {
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:
                                         CGRectMake((self.view.frame.size.width - 30)/2,
                                                    (self.view.frame.size.height - 30)/2,
                                                    30, 30)];
    [activity setColor:[UIColor blackColor]];
    [self.view addSubview:activity];
    [activity startAnimating];
//    NSString *urlString = [NSString stringWithFormat:@"https://www.tryngo.ch/api/getObjects?lat=46.1983922&lng=6.142296100000067&dist=10&limit=3&keyword=guitare"];
//    latLocation = @"46.1983922";
//    lngLocation = @"6.142296100000067";
//    keyWord = @"guitare";
//    NSString *urlString = [NSString stringWithFormat:@"https://www.tryngo.ch/api/getObjects?lat=%@&lng=%@&dist=10&limit=5&keyword=%@", latLocation, lngLocation, keyWord];
    NSString *urlString;
    if (![indexSubCategory isEqualToString:@""]) {
        urlString = [NSString stringWithFormat:@"http://www.tryngo.ch/api/getObjects?lat=%@&lng=%@&dist=10&limit=100&category=%@&keyword=%@", latLocation, lngLocation, indexSubCategory, keyWord];
    } else if (![indexCategory isEqualToString:@""]) {
        urlString = [NSString stringWithFormat:@"http://www.tryngo.ch/api/getObjects?lat=%@&lng=%@&dist=10&limit=100&type=%@&keyword=%@", latLocation, lngLocation, indexCategory, keyWord];
    } else {
        urlString = [NSString stringWithFormat:@"http://www.tryngo.ch/api/getObjects?lat=%@&lng=%@&dist=10&limit=100&keyword=%@", latLocation, lngLocation, keyWord];
    }
    
    NSLog(@"req = %@", urlString);
    
///true request    = [NSString stringWithFormat:@"http://www.tryngo.ch/api/getObjects?lat=%@&lng=%@&dist=10&limit=100&category=%@&keyword=%@", latLocation, lngLocation, category, keyWord];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30.0f];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if([data length] > 0 && error == nil) {
             offersArray = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error:nil];
             int countOffer = 0;
             @try {
                 countOffer = [offersArray count];
             } @catch (NSException *e) {
                 countOffer = 0;
             }
             if (countOffer > 0) {
                 dispatch_async(dispatch_get_main_queue(), ^{
//                 [self create];
                     if ([cityName isEqualToString:@""]) {
                         [titleLabel setText:@"  Near me"];
                     } else {
                         [titleLabel setText:[NSString stringWithFormat:@"  Near me in %@", cityName]];
                     }
                     [offerTableView reloadData];
                     [activity stopAnimating];
                 });
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [titleLabel setText:@"  Near me"];
                     UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"There is no offers here"
                                           message:@""
                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     [alertView show];
                     [offerTableView reloadData];
                     [activity stopAnimating];
                 });
             }
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *alertView = [[UIAlertView alloc]
                                           initWithTitle:@"Error:"
                                           message:@"Error rerquest to server"
                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alertView show];
                 [offerTableView reloadData];
                 [activity stopAnimating];
             });
         }
     }];
}

-(void)getCategoryRequest {
    NSString *urlString = [NSString stringWithFormat:@"https://www.tryngo.ch/api/getCategories"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30.0f];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if([data length] > 0 && error == nil) {
             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error:nil];
             int countCategory = 0;
             @try {
                 countCategory = [json count];
             } @catch (NSException *e) {
                 countCategory = 0;
             }
             if (countCategory > 0) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [categoryArray addObject:@"Select service type"];
                     for (NSString* key in json) {
                         NSDictionary *value = [json objectForKey:key];
                         [categoryArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:key, @"id", [value objectForKey:@"type"], @"name", nil]];
                         NSDictionary *categoriesDictionary = [value objectForKey:@"categories"];
                         NSMutableArray *currentArray = [[NSMutableArray alloc] init];
                         for (NSString* key in categoriesDictionary) {
                             NSDictionary *value = [categoriesDictionary objectForKey:key];
                             NSDictionary *currentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:key, @"id", [value objectForKey:@"title"], @"title", [value objectForKey:@"children"], @"array", nil];
                             [currentArray addObject:currentDictionary];
                         }
                         [allSubCategoryArray addObject:currentArray];
                         subCategoryArray = [NSArray arrayWithObject:@"Sub-category"];
                     }
                 });
             }
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
    currentDevice = [UIDevice currentDevice];
    CGRect sizeTitleView;
    sizeTitleView.origin.x = 0;
    sizeTitleView.origin.y = 20;
    sizeTitleView.size.width = self.view.frame.size.width;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeTitleView.size.height = 50;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeTitleView.size.height = 100;
    }
    UIView *titleView = [[UIView alloc] initWithFrame:sizeTitleView];
    [titleView setBackgroundColor:[UIColor colorWithRed:77.0f/255.0f green:178.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
    [self.view addSubview:titleView];
    
    UIImage *menuImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_top_menu%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeMenuButton;
    sizeMenuButton.size.width = menuImage.size.width / 2;
    sizeMenuButton.size.height = menuImage.size.height / 2;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeMenuButton.origin.x = self.view.frame.size.width - sizeMenuButton.size.width - 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeMenuButton.origin.x = self.view.frame.size.width - sizeMenuButton.size.width - 30;
    }
    sizeMenuButton.origin.y = (titleView.frame.size.height - sizeMenuButton.size.height) / 2;
    menuButton = [[UIButton alloc] initWithFrame:sizeMenuButton];
//    [menuButton setBackgroundColor:[UIColor lightGrayColor]];
    [menuButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    [menuButton setTag:0];
    [menuButton addTarget:self action:@selector(pressMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:menuButton];
    
    CGRect sizeTitleLabel = sizeTitleView;
    sizeTitleLabel.origin.y = 0;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeTitleLabel.size.width = sizeMenuButton.origin.x - 5;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeTitleLabel.size.width = sizeMenuButton.origin.x - 30;
    }
    titleLabel = [[UILabel alloc] initWithFrame:sizeTitleLabel];
    [titleLabel setText:@"  Near me"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [titleLabel setFont:[FONT regularFontWithSize:24]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [titleLabel setFont:[FONT regularFontWithSize:42]];
    }
    [titleView addSubview:titleLabel];
    
    CGRect sizeTableView;
    sizeTableView.origin.x = 0;
    sizeTableView.origin.y = titleView.frame.origin.y + titleView.frame.size.height;
    sizeTableView.size.width = self.view.frame.size.width;
    sizeTableView.size.height = self.view.frame.size.height - sizeTableView.origin.y;
    
    offerTableView = [[UITableView alloc] initWithFrame:sizeTableView];
    offerTableView.delegate = self;
    offerTableView.dataSource = self;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        offerTableView.rowHeight = 110;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        offerTableView.rowHeight = 200;
    }
    offerTableView.separatorColor = [UIColor whiteColor];
    [self.view addSubview:offerTableView];
    
    CGRect sizeSearchView;
    sizeSearchView.origin.x = 0;
    sizeSearchView.origin.y = offerTableView.frame.origin.y + offerTableView.frame.size.height;
    sizeSearchView.size.width = self.view.frame.size.width;
    sizeSearchView.size.height = self.view.frame.size.height / 2;
    searchView = [[UIView alloc] initWithFrame:sizeSearchView];
    [searchView setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:253.0f/255.0f blue:253.0f/255.0f alpha:1.0f]];
    [searchView.layer setBorderColor:[UIColor colorWithRed:229.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f].CGColor];
    [searchView.layer setBorderWidth:1];
    [self.view addSubview:searchView];
    [self createSearchView];
}

-(void)createSearchView {
    float space = 0;
    float borderWidth = 1;
    float borderRadius = 4;
    UIFont *titleFont;
    UIFont *descriptionFont;
    UIColor *descriptionColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    UIColor *borderColor = [UIColor colorWithRed:32.0f/255.0f green:137.0f/255.0f blue:198.0f/255.0f alpha:1.0f];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        space = 10;
        titleFont = [FONT regularFontWithSize:15];
        descriptionFont = [FONT regularFontWithSize:13];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        space = 20;
        titleFont = [FONT regularFontWithSize:31];
        descriptionFont = [FONT regularFontWithSize:27];
    }
    UIImage *elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"btn_drop_list%@", [UserDataSingleton sharedSingleton].Sufix]];
//    float height = [@"A" sizeWithAttributes:@{NSFontAttributeName: titleFont}].height + 10;
    float height = elementImage.size.height / 2;
    
    CGRect sizeLabel;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeLabel.origin.x = 10;
        sizeLabel.origin.y = 20;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeLabel.origin.x = 20;
        sizeLabel.origin.y = 40;
    }
    sizeLabel.size.height = height;
    sizeLabel.size.width = searchView.frame.size.width / 2 - sizeLabel.origin.x * 2;
    
    CGRect sizeField = sizeLabel;
    sizeField.origin.x += searchView.frame.size.width / 2;
    
    UILabel *selectLocationLabel = [[UILabel alloc] initWithFrame:sizeLabel];
    [selectLocationLabel setText:@"Select location"];
    [selectLocationLabel setFont:titleFont];
    [searchView addSubview:selectLocationLabel];
    
    UIView *locationView = [[UIView alloc] initWithFrame:sizeField];
    [locationView setBackgroundColor:[UIColor whiteColor]];
    [locationView.layer setBorderColor:borderColor.CGColor];
    [locationView.layer setBorderWidth:borderWidth];
    [locationView.layer setCornerRadius:borderRadius];
    [searchView addSubview:locationView];
    
    CGRect sizeLocationText = sizeField;
    sizeLocationText.origin.x = sizeField.size.height;
    sizeLocationText.origin.y = 0;
    sizeLocationText.size.width -= sizeLocationText.origin.x;
    
    locationText = [[UITextField alloc] initWithFrame:sizeLocationText];
    [locationText setFont:descriptionFont];
    [locationText setTextColor:descriptionColor];
    [locationText setPlaceholder:@"Your location?"];
    [locationText setReturnKeyType:UIReturnKeyDone];
    [locationText setDelegate:self];
    [locationView addSubview:locationText];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_geo_location%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeGeoImageView;
    sizeGeoImageView.size.height = elementImage.size.height / 2;
    sizeGeoImageView.size.width = elementImage.size.width / 2;
    sizeGeoImageView.origin.x = (locationText.frame.origin.x - sizeGeoImageView.size.width) / 2;
    sizeGeoImageView.origin.y = (locationText.frame.size.height - sizeGeoImageView.size.height) / 2;
    
    UIImageView *geoImageView = [[UIImageView alloc] initWithFrame:sizeGeoImageView];
    [geoImageView setImage:elementImage];
    [locationView addSubview:geoImageView];
    
    sizeLabel.origin.y += sizeLabel.size.height + space;
    sizeField.origin.y = sizeLabel.origin.y;
    
    UILabel *whatYouNeedLabel = [[UILabel alloc] initWithFrame:sizeLabel];
    [whatYouNeedLabel setText:@"What do you need"];
    [whatYouNeedLabel setFont:titleFont];
    [searchView addSubview:whatYouNeedLabel];
    
    UIView *whatYouNeedView = [[UIView alloc] initWithFrame:sizeField];
    [whatYouNeedView setBackgroundColor:[UIColor whiteColor]];
    [whatYouNeedView.layer setBorderColor:borderColor.CGColor];
    [whatYouNeedView.layer setBorderWidth:borderWidth];
    [whatYouNeedView.layer setCornerRadius:borderRadius];
    [searchView addSubview:whatYouNeedView];
    
/*    CGRect sizeLocationText = sizeField;
    sizeLocationText.origin.x = sizeField.size.height;
    sizeLocationText.origin.y = 0;
    sizeLocationText.size.width -= sizeLocationText.origin.x;*/
    
    whatYouNeedText = [[UITextField alloc] initWithFrame:sizeLocationText];
    [whatYouNeedText setFont:descriptionFont];
    [whatYouNeedText setTextColor:descriptionColor];
    [whatYouNeedText setPlaceholder:@"What you need?"];
    [whatYouNeedText setReturnKeyType:UIReturnKeyDone];
    [whatYouNeedText setDelegate:self];
    [whatYouNeedView addSubview:whatYouNeedText];
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_search%@", [UserDataSingleton sharedSingleton].Sufix]];
    CGRect sizeSearchImageView;
    sizeSearchImageView.size.height = elementImage.size.height / 2;
    sizeSearchImageView.size.width = elementImage.size.width / 2;
    sizeSearchImageView.origin.x = (whatYouNeedText.frame.origin.x - sizeSearchImageView.size.width) / 2;
    sizeSearchImageView.origin.y = (whatYouNeedText.frame.size.height - sizeSearchImageView.size.height) / 2;
    
    UIImageView *searchImageView = [[UIImageView alloc] initWithFrame:sizeSearchImageView];
    [searchImageView setImage:elementImage];
    [whatYouNeedView addSubview:searchImageView];
    
    sizeLabel.origin.y += sizeLabel.size.height + space;
    sizeField.origin.y = sizeLabel.origin.y;
    
    elementImage = [UIImage imageNamed:[NSString stringWithFormat:@"btn_drop_list%@", [UserDataSingleton sharedSingleton].Sufix]];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:sizeLabel];
    [categoryLabel setText:@"Product category"];
    [categoryLabel setFont:titleFont];
    [searchView addSubview:categoryLabel];
    
    categoryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [categoryButton setBackgroundColor:[UIColor whiteColor]];
    [categoryButton setFrame:sizeField];
    [categoryButton setTitle:@"Service type" forState:UIControlStateNormal];
    [categoryButton setTitleColor:descriptionColor forState:UIControlStateNormal];
    [categoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [categoryButton.titleLabel setFont:descriptionFont];
    [categoryButton.layer setBorderColor:borderColor.CGColor];
    [categoryButton.layer setBorderWidth:borderWidth];
    [categoryButton.layer setCornerRadius:borderRadius];
    categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, sizeLabel.origin.x, 0, 0);
    [categoryButton setTag:0];
    [categoryButton addTarget:self action:@selector(pressCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:categoryButton];
    
    CGRect sizeCategoryArrowButton;
    sizeCategoryArrowButton.size.height = elementImage.size.height / 2 - 1;
    sizeCategoryArrowButton.size.width = elementImage.size.width / 2;
    sizeCategoryArrowButton.origin.x = categoryButton.frame.size.width - sizeCategoryArrowButton.size.width;
    sizeCategoryArrowButton.origin.y = 0;

//    sizeCategoryArrowButton.origin.x = categoryButton.frame.origin.x + categoryButton.frame.size.width - sizeCategoryArrowButton.size.width;
//    sizeCategoryArrowButton.origin.y = categoryButton.frame.origin.y;
    
    UIButton *categoryArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [categoryArrowButton setFrame:sizeCategoryArrowButton];
    [categoryArrowButton setImage:elementImage forState:UIControlStateNormal];
    [categoryArrowButton setTag:0];
    [categoryArrowButton addTarget:self action:@selector(pressCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
    [categoryButton addSubview:categoryArrowButton];
    
    sizeLabel.origin.y += sizeLabel.size.height + space;
    sizeField.origin.y = sizeLabel.origin.y;
    
    UILabel *subCategoryLabel = [[UILabel alloc] initWithFrame:sizeLabel];
    [subCategoryLabel setText:@"Subcategory"];
    [subCategoryLabel setFont:titleFont];
    [searchView addSubview:subCategoryLabel];
    
    subCategoryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [subCategoryButton setBackgroundColor:[UIColor whiteColor]];
    [subCategoryButton setFrame:sizeField];
    [subCategoryButton setTitle:@"Sub-category" forState:UIControlStateNormal];
    [subCategoryButton setTitleColor:descriptionColor forState:UIControlStateNormal];
    [subCategoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [subCategoryButton.titleLabel setFont:descriptionFont];
    [subCategoryButton.layer setBorderColor:borderColor.CGColor];
    [subCategoryButton.layer setBorderWidth:borderWidth];
    [subCategoryButton.layer setCornerRadius:borderRadius];
    subCategoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    subCategoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, sizeLabel.origin.x, 0, 0);
    [subCategoryButton setTag:1];
    [subCategoryButton addTarget:self action:@selector(pressCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:subCategoryButton];
    
    UIButton *subCategoryArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [subCategoryArrowButton setFrame:sizeCategoryArrowButton];
    [subCategoryArrowButton setImage:elementImage forState:UIControlStateNormal];
    [subCategoryArrowButton setTag:1];
    [subCategoryArrowButton addTarget:self action:@selector(pressCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
    [subCategoryButton addSubview:subCategoryArrowButton];
    
    CGRect sizeSubmitButton;
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizeSubmitButton.origin.x = 50;
        sizeSubmitButton.size.height = [@"Ag" sizeWithAttributes:@{NSFontAttributeName:[FONT boldFontWithSize:15]}].height + space * 2;
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        sizeSubmitButton.origin.x = 70;
        sizeSubmitButton.size.height = [@"Ag" sizeWithAttributes:@{NSFontAttributeName:[FONT boldFontWithSize:31]}].height + space * 2;
    }
    sizeSubmitButton.origin.y = sizeLabel.origin.y + sizeLabel.size.height + space * 2;
    sizeSubmitButton.size.width = searchView.frame.size.width - sizeSubmitButton.origin.x * 2;
//    sizeSubmitButton.size.height = sizeLabel.size.height;
    
//    UIButton *submitButton = [[UIButton alloc] initWithFrame:sizeSubmitButton];
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submitButton setFrame:sizeSubmitButton];
    [submitButton setBackgroundColor:[UIColor colorWithRed:77.0f/255.0f green:178.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
    [submitButton setTitle:@"SUBMIT AND SEARCH" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [submitButton.titleLabel setFont:[FONT boldFontWithSize:15]];
    }
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [submitButton.titleLabel setFont:[FONT boldFontWithSize:31]];
    }
    [submitButton.layer setCornerRadius:borderRadius];
    [submitButton.layer setShadowColor:[UIColor colorWithRed:52.0f/255.0f green:147.0f/255.0f blue:202.0f/255.0f alpha:1.0f].CGColor];
    [submitButton.layer setShadowOffset:CGSizeMake(0, 4)];
    [submitButton.layer setShadowOpacity:1.0f];
    submitButton.layer.masksToBounds = NO;
    [submitButton addTarget:self action:@selector(pressSubmitButton) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:submitButton];
    
    CGRect sizeSearhView = searchView.frame;
    sizeSearhView.size.height = submitButton.frame.origin.y + submitButton.frame.size.height + selectLocationLabel.frame.origin.y;
    [searchView setFrame:sizeSearhView];
    
}

-(void)pressMenuButton:(UIButton *)button {
    if (activeTextField) {
        [activeTextField resignFirstResponder];
        activeTextField = nil;
    }
    if (button.tag == 0) {
        button.tag = 1;
        CGRect sizeNewTableView = offerTableView.frame;
        sizeNewTableView.size.height -= searchView.frame.size.height;
        CGRect sizeNewSearchView = searchView.frame;
        sizeNewSearchView.origin.y -= sizeNewSearchView.size.height;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
            [offerTableView setFrame:sizeNewTableView];
            [searchView setFrame:sizeNewSearchView];
        } completion:nil];
    } else {
        button.tag = 0;
        CGRect sizeNewTableView = offerTableView.frame;
        sizeNewTableView.size.height += searchView.frame.size.height;
        CGRect sizeNewSearchView = searchView.frame;
        sizeNewSearchView.origin.y += sizeNewSearchView.size.height;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
            [offerTableView setFrame:sizeNewTableView];
            [searchView setFrame:sizeNewSearchView];
        } completion:nil];
    }
}

-(void)pressSubmitButton {
    if (activeTextField) {
        [activeTextField resignFirstResponder];
        activeTextField = nil;
    }
    cityName = locationText.text;
    keyWord = whatYouNeedText.text;
    if ([locationText.text isEqualToString:@""]){
        isLocation = false;
        [self getUserLocation];
    } else {
        [self getCityCoords:cityName];
    }
    [self pressMenuButton:menuButton];
//    [self getRequest];
}

-(void)pressCategoryButton:(UIButton *)button {
    NSArray *contentArray;
    if (button.tag == 0) {
        contentArray = categoryArray;
    } else if (button.tag == 1) {
        contentArray = subCategoryArray;
    }
    int countContent = 0;
    @try {
        countContent = [contentArray count];
    } @catch (NSException *e) {
        countContent = 0;
    }
    if (countContent > 1) {
        popupView = [[CategoryPopover alloc] initWithFrame:self.view.frame andTag:button.tag andContent:contentArray];
        popupView.delegate = self;
        [self.view addSubview:popupView];
    }
}

-(void)getUserLocation{
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *curr_loc = [locations lastObject];
    [self updateUserLocation:curr_loc];
    [locationManager stopUpdatingLocation];
}

- (void)updateUserLocation:(CLLocation *)pointLocation{
    user_loc.latitude = pointLocation.coordinate.latitude;
    user_loc.longitude = pointLocation.coordinate.longitude;
    if (!isLocation) {
        latLocation = [NSString stringWithFormat:@"%f", pointLocation.coordinate.latitude];
        lngLocation = [NSString stringWithFormat:@"%f", pointLocation.coordinate.longitude];
        isLocation = true;
        [self getRequest];
    }
}

-(void)getCityCoords:(NSString*)name{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:name completionHandler:^(NSArray *placemarks,NSError *error){
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        latLocation = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
        lngLocation = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
        [self getRequest];
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int countOffer = 0;
    @try {
        countOffer = [offersArray count];
    } @catch (NSException *e) {
        countOffer = 0;
    }

    return countOffer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //поиск ячейки
    OfferTableViewCell *cell = (OfferTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //если ячейка не найдена - создаем новую
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyCell"owner:self options:nil];
//        cell = [nib objectAtIndex:0];
        CGRect cellFrame;
        cellFrame.origin.x = cellFrame.origin.y = 0;
        cellFrame.size.width = tableView.frame.size.width;
        cellFrame.size.height = tableView.rowHeight;
        cell = [[OfferTableViewCell alloc] initWithFrame:cellFrame];
    }
    
//    cell.textLabel.text = [students objectAtIndex:indexPath.row];
    NSDictionary *offerDictionary = [offersArray objectAtIndex:indexPath.row];
    cell.index = [offerDictionary objectForKey:@"id"];
    cell.offerImageString = [offerDictionary objectForKey:@"image"];
    cell.offerName = [offerDictionary objectForKey:@"title"];
    cell.offerPlace = [offerDictionary objectForKey:@"location"];
    cell.userImageString = [offerDictionary objectForKey:@"user_photo"];
    cell.userId = [offerDictionary objectForKey:@"user_id"];
    cell.userName = [offerDictionary objectForKey:@"username"];
//    cell.price = [offerDictionary objectForKey:@"cost"];
    cell.cost = [offerDictionary objectForKey:@"cost"];
    cell.costUnit = [offerDictionary objectForKey:@"cost_unit"];
    cell.rating = @"0";
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OneOfferViewController *oneOfferViewController = [[OneOfferViewController alloc] initWithIndex:[[offersArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
    [self presentViewController:oneOfferViewController animated:NO completion:nil];
}

- (void) keyboardWillShow:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect sizeNewSearchView = searchView.frame;
    sizeNewSearchView.origin.y -= kbSize.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        searchView.frame = sizeNewSearchView;
    }];
}

- (void) keyboardDidHide:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect sizeNewSearchView = searchView.frame;
    sizeNewSearchView.origin.y += kbSize.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        searchView.frame = sizeNewSearchView;
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
/*    [textField resignFirstResponder];
    activeTextField = nil;*/
    [self pressSubmitButton];
    return YES;
}

-(void)selectCategory:(int)index andType:(int)tag andName:(NSString *)name{
    [self removePopup];
    
    if (tag == 0) {
        if (index == 0) {
            subCategoryArray = [NSArray arrayWithObject:@"Sub-category"];
            indexCategory = @"";
        } else {
            subCategoryArray = [allSubCategoryArray objectAtIndex:index - 1];
            indexCategory = [[categoryArray objectAtIndex:index] objectForKey:@"id"];
        }
        indexSubCategory = @"";
        [categoryButton setTitle:name forState:UIControlStateNormal];
        [subCategoryButton setTitle:@"Sub-category" forState:UIControlStateNormal];
    } else if (tag == 1) {
        if (index == 0) {
            indexSubCategory = @"";
        } else {
            indexSubCategory = [NSString stringWithFormat:@"%i", index];
        }
        [subCategoryButton setTitle:name forState:UIControlStateNormal];
    }
}

-(void)removePopup {
    for (UIView *subview in [popupView subviews]) {
        [subview removeFromSuperview];
    }
    [popupView removeFromSuperview];
    popupView = nil;
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
