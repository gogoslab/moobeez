//
//  TmdbCharacter.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "DatabaseItem.h"

@class TmdbMovie;
@class TmdbPerson;

@interface TmdbCharacter : DatabaseItem

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) TmdbMovie* movie;
@property (strong, nonatomic) TmdbPerson* person;

@end
