//
//  Teebee.h
//  Moobeez
//
//  Created by Radu Banea on 30/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "Bee.h"

typedef enum TeebeeType {
    
    TeebeeNoneType = 0,
    TeebeeToSeeType = 1,
    TeebeeSoonType = 2,
    
    TeebeeAllType,
    
} TeebeeType;

@class TmdbTV;

@interface Teebee : Bee

@property (readwrite, nonatomic) TeebeeType type;

@property (strong, nonatomic) NSMutableArray* seasons;

+ (id)teebeeWithTmdbTV:(TmdbTV*)tv;

@end