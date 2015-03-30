//
//  OfferTableViewCell.h
//  tryngo
//
//  Created by michail on 16/03/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APICache.h"

@interface OfferTableViewCell : UITableViewCell
@property (nonatomic, retain) NSString *index;
@property (nonatomic, retain) NSString *offerImageString;
@property (nonatomic, retain) NSString *offerName;
@property (nonatomic, retain) NSString *offerPlace;
@property (nonatomic, retain) NSString *userImageString;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *userName;
//@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *costUnit;
@property (nonatomic, retain) NSString *cost;
@property (nonatomic, retain) NSString *rating;


@end
