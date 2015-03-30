//
//  OfferViewController.h
//  tryngo
//
//  Created by michail on 13/03/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OfferTableViewCell.h"
#import "CategoryPopover.h"
#import "FONT.h"

@interface OfferViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate, CategoryPopoverDelegate>
@end
