//
//  URLConnection.h
//  ConnectionLibrary
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLConnection : NSURLConnection 
{
}

@property (readwrite, nonatomic) BOOL dontProcessResponse;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSMutableData* data;
@property (nonatomic, strong) NSMutableData* responseData;
@property (nonatomic, strong) NSMutableDictionary* userInfo;

@end
