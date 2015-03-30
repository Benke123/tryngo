//
//  CategoryPopover.h
//  tryngo
//
//  Created by michail on 24/03/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FONT.h"

@protocol CategoryPopoverDelegate <NSObject>
-(void)selectCategory:(int)index andType:(int)tag andName:(NSString *)name;
-(void)removePopup;
@end

@interface CategoryPopover : UIView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id <CategoryPopoverDelegate> delegate;
- (id)initWithFrame:(CGRect)frame andTag:(int)tag andContent:(NSArray *)contentArray;
@end
