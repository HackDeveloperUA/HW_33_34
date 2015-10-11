//
//  ASPerson.m
//  HW_33_34
//
//  Created by MD on 19.06.15.
//  Copyright (c) 2015 hh. All rights reserved.
//

#import "ASPerson.h"

@implementation ASPerson

- (instancetype)initWithName
{
    NSArray *firstNames = @[ @"Alice", @"Bob", @"Charlie", @"Quentin", @"Ivan" ];
    NSArray *lastNames = @[ @"Smith", @"Jones", @"Smith", @"Alberts", @"Ukrainsky" ];
    NSArray *ages = @[ @24, @27, @33, @31, @40, @60, @50, @55 ];

    
    
    self = [super init];
    if (self) {
        
        self.firstName = [firstNames objectAtIndex:arc4random()%5];
        self.lastName  = [lastNames objectAtIndex:arc4random()%5];
        self.age       = [ages objectAtIndex:arc4random()%8];
    
    }
    return self;
}



- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@", self.firstName, self.lastName, self.age];
}


@end
