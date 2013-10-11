//
//  Constants.h
//  Moobeez
//
//  Created by Radu Banea on 12/31/12.
//  Copyright (c) 2012 Goggzy. All rights reserved.
//

#define DOCUMENTS_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define MY_MOVIES_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:@"Movies.plist"]

#define EndLoadingNotification @"endLoading"

#define DidInitCalendarStoreNotification @"didInitCalendarStore"
#define DidFailToInitCalendarStoreNotification @"didFailToInitCalendarStore"

#define DidInitFacebookNotification @"didInitFacebook"
#define DidLoadFacebookNotification @"didLoadFacebook"

#define DidChangeMyMoviesNotification @"didChangeMyMovies"
#define DidLoadMovieNotification @"didLoadMovie"
#define WillLoadMovieNotification @"willLoadMovie"
#define DidLoadMoviesNotification @"didLoadMovies"

#define TmdbApiKey @"58941f25d1c85eb024206cbf1a9a89b0"

#define MainTmdbUrl @"http://api.themoviedb.org/3/"

#define UrlConfiguration @"configuration"
#define UrlSearchMovie @"search/movie"
#define UrlMovie(movieId) [NSString stringWithFormat:@"movie/%@",movieId]
#define UrlPerson(personId) [NSString stringWithFormat:@"person/%@",personId]

#define UrlUpcoming @"movie/upcoming"
#define UrlNowPlaying @"movie/now_playing"
#define UrlPopular @"movie/popular"
#define UrlTopRated @"movie/top_rated"
