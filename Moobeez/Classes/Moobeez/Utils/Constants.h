//
//  Constants.h
//  Moobeez
//
//  Created by Radu Banea on 12/31/12.
//  Copyright (c) 2012 Goggzy. All rights reserved.
//

#define DOCUMENTS_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define MY_MOVIES_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:@"Movies.plist"]

#define OLD_DATABASE_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:@"MoobeezDatabase"]

#define MY_DATABASE_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:@"MoobeezDatabase_2.0"]

#define EndLoadingNotification @"endLoading"

#define DidInitCalendarStoreNotification @"didInitCalendarStore"
#define DidFailToInitCalendarStoreNotification @"didFailToInitCalendarStore"

#define DidInitFacebookNotification @"didInitFacebook"
#define DidLoadFacebookNotification @"didLoadFacebook"

#define DidChangeMyMoviesNotification @"didChangeMyMovies"
#define DidLoadMovieNotification @"didLoadMovie"
#define WillLoadMovieNotification @"willLoadMovie"
#define DidLoadMoviesNotification @"didLoadMovies"

typedef void (^EmptyHandler) ();