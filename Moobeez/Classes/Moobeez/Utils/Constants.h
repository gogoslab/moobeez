//
//  Constants.h
//  Moobeez
//
//  Created by Radu Banea on 12/31/12.
//  Copyright (c) 2012 Goggzy. All rights reserved.
//

#define DOCUMENTS_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define MY_MOVIES_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:@"Movies.plist"]

#define GROUP_PATH [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.moobeez"] path]

#define DATABASE_NAME @"MoobeezDatabase"
#define DATABASE_VERSION @"3.0.0"
#define CURRENT_DATABASE_PATH [GROUP_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", DATABASE_NAME, DATABASE_VERSION]]
#define OLD_DATABASE_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", DATABASE_NAME, DATABASE_VERSION]]
#define BACKUP_DATABASE_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:@"BackupDatabase"]
#define VERSION_OF_DATABASE(database) ([[[database lastPathComponent] componentsSeparatedByString:@"_"] count] > 1 ? [[database lastPathComponent] componentsSeparatedByString:@"_"][1] : @"")

#define EndLoadingNotification @"endLoading"

#define DidInitCalendarStoreNotification @"didInitCalendarStore"
#define DidFailToInitCalendarStoreNotification @"didFailToInitCalendarStore"

#define DidInitFacebookNotification @"didInitFacebook"
#define DidLoadFacebookNotification @"didLoadFacebook"

#define DidChangeMyMoviesNotification @"didChangeMyMovies"
#define DidLoadMovieNotification @"didLoadMovie"
#define WillLoadMovieNotification @"willLoadMovie"
#define DidLoadMoviesNotification @"didLoadMovies"

#define StringInteger(Integer) [NSString stringWithFormat:@"%ld", (long) Integer]

#define DidUpdateWatchedEpisodesNotification @"DidUpdateWatchedEpisodesNotification" 

#define ResourceName(name) [NSString stringWithFormat:@"%@%@", name, ([UIScreen mainScreen].scale > 1.0 ? @"@2x" : @"")]

typedef void (^EmptyHandler) ();
typedef void (^CompleteHandler) (BOOL completed);

typedef enum WebserviceResultCode {
    WebserviceResultError = 0,
    WebserviceResultOk = 1
} WebserviceResultCode;

