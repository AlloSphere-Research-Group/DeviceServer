#import "BundleLoader.h"

@implementation BundleLoader

- (void) awakeFromNib {
	[self performSelector:@selector(delayedInit) withObject:nil afterDelay:.5];
}

- (void) delayedInit {
	NSBundle *appBundle;
	NSArray *bundlePaths;
	
	appBundle = [NSBundle mainBundle];
	bundlePaths = [appBundle pathsForResourcesOfType:@"bundle"
										 inDirectory:@"plugins"];
	for(NSString *path in bundlePaths) {
		NSBundle *bundle = [NSBundle bundleWithPath:path];
		[bundle load];
		Class principal = [bundle principalClass];
		
		
		topLevelObjs = [[NSMutableArray alloc] init];
		NSDictionary*        nameTable = [NSDictionary dictionaryWithObjectsAndKeys:
										  bundle, NSNibOwner,
										  topLevelObjs, NSNibTopLevelObjects,
										  nil];
		
		if (![bundle loadNibFile:@"Interface" externalNameTable:nameTable withZone:nil])
			NSLog(@"Warning! Could not load myNib file.\n");
		
		id principalInstance;
		for(id obj in topLevelObjs) {			
			if([obj isKindOfClass:principal]) {
				principalInstance = obj;
				break;
			}
		}
		
		if([principalInstance shouldDisplayInterface]) {
			NSTabViewItem *tvi = [[NSTabViewItem alloc] initWithIdentifier:nil];
			[tvi setLabel:[principalInstance name]];
			[tvi setView:[principalInstance view]];
			[tabs addTabViewItem:tvi];			
		}
	}
	
}

- (void) dealloc {
	[topLevelObjs release];
	[super dealloc];
}

@end
