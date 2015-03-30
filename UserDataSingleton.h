//
//  UserDataSingleton.h
//  Word Trail
//
//  Created by michail on 08/12/14.
//  Copyright (c) 2014 Rhinoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataSingleton : NSObject

@property (nonatomic, strong)  NSUserDefaults  *userDefaults;
@property (nonatomic, strong) NSString *Sufix;
@property (nonatomic, strong) NSString *offerImagePrefix;
@property (nonatomic, strong) NSString *thumbImagePrefix;
@property (nonatomic, strong) NSString *userImagePrefix;
@property (nonatomic, assign) float scale ;
@property (nonatomic, assign) int IOSDevice ;
+ (UserDataSingleton *)sharedSingleton;

@end
