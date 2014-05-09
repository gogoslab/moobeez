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
#define UrlPerson(personId) [NSString stringWithFormat:@"person/%ld",personId]
#define UrlTv(movieId) [NSString stringWithFormat:@"tv/%ld",movieId]
#define UrlTvSeason(movieId, seasonNumber) [NSString stringWithFormat:@"tv/%ld/season/%ld", movieId, seasonNumber]

#define UrlUpcoming @"movie/upcoming"
#define UrlNowPlaying @"movie/now_playing"
#define UrlPopular @"movie/popular"
#define UrlTopRated @"movie/top_rated"

#define UrlSearchTv @"search/tv"

#define UrlTvOnTheAir @"tv/on_the_air"
#define UrlTvPopular @"tv/popular"
#define UrlTvTopRated @"tv/top_rated"

#define UrlSearch @"search"

#import "ConfigurationConnection.h"

#import "MovieConnection.h"
#import "MovieImagesConnection.h"
#import "MovieTrailersConnection.h"

#import "PersonConnection.h"

#import "SearchMovieConnection.h"

#import "MoviesListConnection.h"

#import "SearchMovieConnection.h"


#import "TvConnection.h"

#import "SearchTvConnection.h"

#import "TVsListConnection.h"

#import "TvSeasonConnection.h"

#import "TvImagesConnection.h"

#import "SearchConnection.h"

#endif
