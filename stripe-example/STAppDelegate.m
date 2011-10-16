#import "STAppDelegate.h"
#import "STRootViewController.h"

@implementation STAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    STRootViewController *rootViewController = [[STRootViewController alloc] init];
    
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:rootViewController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
