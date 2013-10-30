//
//  TmdbConnections.h
//  Moobeez
//
//  Created by Radu Banea on 10/11/13.
//  Copyright (c) 2013 Goggzy. All rights reserved.
//

#ifndef Moobeez_TmdbConnections_h
#define Moobeez_TmdbConnections_h

#define TmdbApiKey @"58941f25d1c85eb024206cbf1a9a89b0"

#define MainTmdbUrl @"http://api.themoviedb.org/3/"

#define UrlConfiguration @"configuration"
#define UrlSearchMovie @"search/movie"
#define UrlMovie(movieId) [NSString stringWithFormat:@"movie/%ld",movieId]
#define UrlPerson(personId) [NSString stringWithFormat:@"person/%@",personId]

#define UrlUpcoming @"movie/upcoming"
#define UrlNowPlaying @"movie/now_playing"
#define UrlPopular @"movie/popular"
#define UrlTopRated @"movie/top_rated"


#import "ConfigurationConnection.h"
#import "MovieConnection.h"

#endif
