//
//  YouTubeViewController.m
//  Moobeez
//
//  Created by Radu Banea on 21/01/14.
//  Copyright (c) 2014 Goggzy. All rights reserved.
//

#import "YouTubeViewController.h"

@interface YouTubeViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation YouTubeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *videoURL = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@?rel=0&showinfo=0", self.youtubeId];
    
    NSString *videoHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <head>\
                           <style type=\"text/css\">\
                           iframe {position:absolute; top:50%%; margin-top:-150px;}\
                           body {background-color:#000; margin:0;}\
                           </style>\
                           </head>\
                           <body>\
                           <iframe width=\"100%%\" height=\"320\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
                           </body>\
                           </html>", videoURL];
    
    [self.webView loadHTMLString:videoHTML baseURL:nil];
    
    
    /*
    NSError *error = nil;
    
    //Prepare the HTML from the template
    NSString *template = [NSString stringWithContentsOfFile:
                          [[NSBundle mainBundle]
                           pathForResource:@"YouTubeTemplate" ofType:@"txt"]
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    NSString *htmlStr = [NSString stringWithFormat: template,
                         self.webView.frame.size.width, self.webView.frame.size.height,
                         self.webView.frame.size.width, self.webView.frame.size.height,
                         self.youtubeId];
    
    //Write the HTML file to disk
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *tmpFile = [tmpDir
                         stringByAppendingPathComponent: @"video.html"];
    [htmlStr writeToFile:tmpFile atomically:TRUE
                encoding: NSUTF8StringEncoding error:NULL];
    //Enable autoplay
    self.webView.mediaPlaybackRequiresUserAction = NO;
    
    //Load the HTML
    [self.webView loadRequest:[NSURLRequest requestWithURL:
                                      [NSURL fileURLWithPath:tmpFile isDirectory:NO]]];
    
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
