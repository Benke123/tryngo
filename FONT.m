//
//  FONT.m
//  Word Trail
//
//  Created by michail on 05.12.14.
//  Copyright (c) 2014 Rhinoda. All rights reserved.
//

#import "FONT.h"

@implementation FONT
+ (UIFont *)regularFontWithSize:(CGFloat)size {
//    return [UIFont fontWithName:@"ArialMT" size:size];
    return [UIFont fontWithName:@"PTSans-Regular" size:size];
}

+ (UIFont *)boldFontWithSize:(CGFloat)size {
//    return [UIFont fontWithName:@"Arial-BoldMT" size:size];
    return [UIFont fontWithName:@"PTSans-Bold" size:size];
}

@end
