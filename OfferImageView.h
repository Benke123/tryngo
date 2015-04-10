//
//  OfferImageView.h
//  tryngo
//
//  Created by michail on 06/04/15.
//  Copyright (c) 2015 Rhinoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OfferImageViewDelegate <NSObject>
-(void)removeOfferImage;
@end

@interface OfferImageView : UIView <UIWebViewDelegate>
@property (nonatomic, weak) id <OfferImageViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame andImageIndex:(NSString *)imageIndex andImageName:(NSString *)imageName;
@end
