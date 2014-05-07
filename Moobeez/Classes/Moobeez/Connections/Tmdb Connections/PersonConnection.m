//
//  PersonConnection.m
//  Moobeez
//
//  Created by Radu Banea on 11/05/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import "PersonConnection.h"
#import "Moobeez.h"

@interface PersonConnection ()

@property (readwrite, nonatomic) NSInteger tmdbId;
@property (copy, nonatomic) ConnectionPersonHandler customHandler;

@end

@implementation PersonConnection

- (id)initWithTmdbId:(NSInteger)tmdbId completionHandler:(ConnectionPersonHandler)handler {
    
    self.tmdbId = tmdbId;
    
    self.customHandler = handler;
    
    if ([Cache cachedPersons][StringInteger((long)self.tmdbId)]) {
        [self performSelector:@selector(cachedResponse) withObject:nil afterDelay:0.01];
        return [self initFakeConnection];
    }
    

    self = [super initWithParameters:[NSDictionary dictionaryWithObject:@"combined_credits,images" forKey:@"append_to_response"] completionHandler:^(WebserviceResultCode code, NSMutableDictionary *resultDictionary, NSError *error) {
        
        NSLog(@"result: %@", resultDictionary);

        if (code == WebserviceResultOk) {
        
            TmdbPerson* tmdbPerson = [[TmdbPerson alloc] initWithTmdbDictionary:resultDictionary];
        
            [Cache cachedPersons][StringInteger((long)tmdbId)] = tmdbPerson;
            
            self.customHandler(code, tmdbPerson);
        }
        else {
            self.customHandler(code, nil);
        }
    }];
    
    return self;
}

- (NSString*)defaultUrlSubpath {
    return UrlPerson((long)self.tmdbId);
}

- (void)cachedResponse {
    
    [self.activityIndicator stopAnimating];
    self.customHandler(WebserviceResultOk, [Cache cachedPersons][StringInteger((long)self.tmdbId)]);
    
}



@end
