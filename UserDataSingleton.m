//
//  UserDataSingleton.m
//  Word Trail
//
//  Created by michail on 08/12/14.
//  Copyright (c) 2014 Rhinoda. All rights reserved.
//

#import "UserDataSingleton.h"

@implementation UserDataSingleton

@synthesize userDefaults;
@synthesize Sufix;
@synthesize offerImagePrefix;
@synthesize thumbImagePrefix;
@synthesize userImagePrefix;
@synthesize scale ;
@synthesize IOSDevice ;

static UserDataSingleton *sharedSingleton = NULL;

- (id)init
{
    self = [super init];
    if (self) {
        // Work your initialising magic here as you normally would
        
    }
    return self;
}

+ (UserDataSingleton *)sharedSingleton {
    if (!sharedSingleton || sharedSingleton == NULL) {
		sharedSingleton = [UserDataSingleton new];
	}
	return sharedSingleton;
}


@end
