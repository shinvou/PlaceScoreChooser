//
//  Tweak.xm
//  PlaceScoreChooser
//
//  Created by Timm Kandziora on 15.03.14.
//  Copyright (c) 2014 Timm Kandziora. All rights reserved.
//

@interface GameViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
@property (assign) int score;
-(void)pauseGame;
-(void)resumeGame;
@end

@interface ScoreView : UIView
-(void)setLeftScore:(int)score WithAnimation:(BOOL)animation;
@end

@interface NotificationsViewController : UITableViewController
-(void)viewDidLoad;
@end

@interface ProfileViewController : UIViewController
-(void)viewDidLoad;
@end

@interface SuccessFailViewController : UIViewController
-(void)viewDidLoad;
@end

static BOOL showMenu = YES;
static UIWindow *window = nil;

%hook AppDelegate

- (void)applicationDidBecomeActive:(id)application
{
    window = MSHookIvar<UIWindow *>(self, "_window");
}

%end

%hook NotificationsViewController

- (void)viewDidLoad
{
    %orig;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

%end

%hook ProfileViewController

- (void)viewDidLoad
{
    %orig;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

%end

%hook SuccessFailViewController

- (void)viewDidLoad
{
    %orig;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

%end

%hook GameViewController

- (void)viewDidLoad
{
    %orig;
    
    UIView *gotBottomView = MSHookIvar<UIView *>(self, "_bottomView");
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapRecognizer setNumberOfTapsRequired:3];
    [gotBottomView addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
}

- (void)pauseGame
{
    %orig;
    
    if (!showMenu) {
        UIView *view = [[[[window subviews] objectAtIndex:0] subviews] objectAtIndex:2];
        view.hidden = YES;
    }
}

%new
- (void)tapped:(UISwipeGestureRecognizer *)gesture
{
    showMenu = NO;
    [self pauseGame];
    
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"PlaceScoreChoser" message:@"Set a new score, it will be displayed in just a second.\nCopyright © 2014 Timm Kandziora." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [myAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [myAlert setDelegate:self];
    
    UITextField *textField = [myAlert textFieldAtIndex:0];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setPlaceholder:@"Score ..."];
    [textField setDelegate:self];
    
    [myAlert show];
    [myAlert release];
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Ok"]) {
        [self resumeGame];
        showMenu = YES;
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *newScoreString = textField.text;
        
        if (newScoreString.intValue > 0) {
            self.score = newScoreString.intValue;
            [self performSelector:@selector(updateScoreView) withObject:nil afterDelay:1.0];
        }
    }
}

%new
- (void)updateScoreView
{
    ScoreView *gotScoreView = MSHookIvar<ScoreView *>(self, "_scoreView");
    [gotScoreView setLeftScore:self.score WithAnimation:YES];
}

%end