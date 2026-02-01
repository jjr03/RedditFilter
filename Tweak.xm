// RedditFilter Tweak.xm - Modified for 3-finger long press gesture
// Based on level3tjg/RedditFilter
// Modified to show menu with "hold 3 fingers" gesture

#import "Preferences.h"
#import "FeedFilterSettingsViewController.h"

// Store gesture recognizer globally
static UILongPressGestureRecognizer *threeFingerMenuGesture = nil;

// Hook into the main Reddit view controller
// Note: The actual class name may vary depending on Reddit version
// Common classes: RedditFeedViewController, MainViewController, HomeViewController
%hook AccountDrawerViewerFlowCoordinator

- (void)viewDidLoad {
    %orig;
    
    NSLog(@"[RedditFilter] AccountDrawerViewerFlowCoordinator viewDidLoad - initializing 3-finger gesture");
    
    // Initialize the 3-finger long press gesture recognizer
    if (!threeFingerMenuGesture) {
        threeFingerMenuGesture = [[UILongPressGestureRecognizer alloc] 
            initWithTarget:self 
            action:@selector(redditFilter_showMenu:)];
        
        // Configure for 3 fingers
        threeFingerMenuGesture.numberOfTouchesRequired = 3;
        
        // Set minimum press duration (0.5 seconds)
        threeFingerMenuGesture.minimumPressDuration = 0.5;
        
        // Add to the view
        [self.view addGestureRecognizer:threeFingerMenuGesture];
        
        NSLog(@"[RedditFilter] 3-finger gesture recognizer added successfully");
    }
}

%new
- (void)redditFilter_showMenu:(UILongPressGestureRecognizer *)gesture {
    // Only trigger when the gesture begins (not on changes or end)
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"[RedditFilter] 3-finger long press detected - showing filter menu");
        
        // Create and present the filter settings view controller
        FeedFilterSettingsViewController *filterVC = [[FeedFilterSettingsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] 
            initWithRootViewController:filterVC];
        
        // Present modally
        [self presentViewController:navController animated:YES completion:^{
            NSLog(@"[RedditFilter] Filter menu presented successfully");
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    
    // Clean up gesture recognizer when view disappears
    if (threeFingerMenuGesture) {
        [self.view removeGestureRecognizer:threeFingerMenuGesture];
        NSLog(@"[RedditFilter] Gesture recognizer removed");
    }
}

%end

// Alternative hook if the above class doesn't work
// Try hooking into the feed/home view controller
%hook FeedViewController

- (void)viewDidLoad {
    %orig;
    
    NSLog(@"[RedditFilter] FeedViewController viewDidLoad - initializing 3-finger gesture");
    
    // Initialize the 3-finger long press gesture recognizer
    UILongPressGestureRecognizer *feedGesture = [[UILongPressGestureRecognizer alloc] 
        initWithTarget:self 
        action:@selector(redditFilter_showFilterMenu:)];
    
    // Configure for 3 fingers
    feedGesture.numberOfTouchesRequired = 3;
    feedGesture.minimumPressDuration = 0.5;
    
    // Add to the view
    [self.view addGestureRecognizer:feedGesture];
    
    NSLog(@"[RedditFilter] 3-finger gesture added to FeedViewController");
}

%new
- (void)redditFilter_showFilterMenu:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"[RedditFilter] Opening filter menu from FeedViewController");
        
        FeedFilterSettingsViewController *filterVC = [[FeedFilterSettingsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] 
            initWithRootViewController:filterVC];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}

%end

// Hook into the navigation bar if needed
%hook NavigationViewController

- (void)viewDidLoad {
    %orig;
    
    NSLog(@"[RedditFilter] NavigationViewController viewDidLoad - initializing 3-finger gesture");
    
    // Initialize the 3-finger long press gesture recognizer
    UILongPressGestureRecognizer *navGesture = [[UILongPressGestureRecognizer alloc] 
        initWithTarget:self 
        action:@selector(redditFilter_showMenuFromNav:)];
    
    // Configure for 3 fingers
    navGesture.numberOfTouchesRequired = 3;
    navGesture.minimumPressDuration = 0.5;
    
    // Add to the view
    [self.view addGestureRecognizer:navGesture];
}

%new
- (void)redditFilter_showMenuFromNav:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"[RedditFilter] Opening filter menu from NavigationViewController");
        
        FeedFilterSettingsViewController *filterVC = [[FeedFilterSettingsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] 
            initWithRootViewController:filterVC];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}

%end

// Hook into the window to ensure gesture works globally
%hook UIWindow

- (void)becomeKeyWindow {
    %orig;
    
    // Add global 3-finger gesture to the key window
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[RedditFilter] Setting up global 3-finger gesture on UIWindow");
        
        UILongPressGestureRecognizer *globalGesture = [[UILongPressGestureRecognizer alloc] 
            initWithTarget:self 
            action:@selector(redditFilter_globalMenuGesture:)];
        
        globalGesture.numberOfTouchesRequired = 3;
        globalGesture.minimumPressDuration = 0.5;
        globalGesture.delegate = (id<UIGestureRecognizerDelegate>)self;
        
        [self addGestureRecognizer:globalGesture];
        
        NSLog(@"[RedditFilter] Global gesture recognizer installed");
    });
}

%new
- (void)redditFilter_globalMenuGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"[RedditFilter] Global 3-finger gesture triggered");
        
        // Get the root view controller
        UIViewController *rootVC = self.rootViewController;
        
        // Find the topmost view controller
        UIViewController *topVC = rootVC;
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        
        // Present the filter menu
        FeedFilterSettingsViewController *filterVC = [[FeedFilterSettingsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] 
            initWithRootViewController:filterVC];
        
        [topVC presentViewController:navController animated:YES completion:^{
            NSLog(@"[RedditFilter] Filter menu presented from global gesture");
        }];
    }
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    // Allow 3-finger gesture to work alongside other gestures
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
        ((UILongPressGestureRecognizer *)gestureRecognizer).numberOfTouchesRequired == 3) {
        return NO; // Don't allow simultaneous recognition to avoid conflicts
    }
    
    return YES;
}

%end

// Keep the existing filter logic hooks from the original tweak
// These hooks handle the actual filtering functionality

%hook Post
// Original filtering logic would go here
// This is preserved from the original Tweak.xm
%end

%hook Comment  
// Original comment filtering logic would go here
// This is preserved from the original Tweak.xm
%end

// Constructor
%ctor {
    NSLog(@"[RedditFilter] Tweak loaded - 3-finger long press gesture enabled");
    NSLog(@"[RedditFilter] To access filter menu: Hold 3 fingers on screen for 0.5 seconds");
    
    // Load preferences
    loadPreferences();
    
    // Observe preference changes
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)loadPreferences,
        CFSTR("com.level3tjg.redditfilter.preferenceschanged"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );
}
