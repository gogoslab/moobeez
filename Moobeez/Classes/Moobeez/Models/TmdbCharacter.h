//
//  TmdbCharacter.h
//  Moobeez
//
//  Created by Radu Banea on 10/23/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TmdbMovie;
@class TmdbPerson;
@class TmdbCharacter;
@class CharacterCell;

@interface TmdbCharacter : NSObject

@property (readonly, nonatomic) NSInteger id;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) TmdbMovie* movie;
@property (strong, nonatomic) TmdbPerson* person;

@end
