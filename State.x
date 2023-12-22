#import <Foundation/Foundation.h>
#import <rootless.h>
#import "State.h"

static NSString *kCode = @"com.beepserv.code";
static NSString *kSecret = @"com.beepserv.secret";
static NSString *kConnected = @"com.beepserv.connected";
static NSString *kError = @"com.beepserv.error";
static NSString *stateFile = ROOT_PATH_NS(@"/var/mobile/.beepserv_state");

@implementation BPState
- (instancetype __nonnull)initWithCode:(NSString * __nullable)code
					            secret:(NSString * __nullable)secret
				             connected:(BOOL)connected
				                 error:(NSError * __nullable)error {
	self = [super init];
	self.code = code;
	self.secret = secret;
	self.connected = connected;
	self.error = error;
	return self;
}

- (NSString * __nonnull)description {
	return [NSString stringWithFormat:@"<BPState code:%@ secret:%@ connected:%d error:%@", self.code, self.secret, self.connected, self.error];
}

- (void)writeToDiskWithError:(NSError * __nullable * __nullable)writeErr {
	NSMutableDictionary *state = @{
		kConnected: @(self.connected)
	}.mutableCopy;

	if (self.code)
		state[kCode] = self.code;

	if (self.secret)
		state[kSecret] = self.secret;

	if (self.error)
		state[kError] = self.error;

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", stateFile]];
	[state writeToURL:url error:writeErr];
}

+ (instancetype __nullable)readFromDiskWithError:(NSError * __nullable * __nullable)readErr {
	if (![NSFileManager.defaultManager fileExistsAtPath:stateFile isDirectory:nil])
		return nil;

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", stateFile]];
	NSDictionary *state = [NSDictionary dictionaryWithContentsOfURL:url error:readErr];

	if (readErr && *readErr)
		return nil;

	BOOL connected = ((NSNumber *)state[kConnected]).boolValue;
	return [BPState.alloc initWithCode:state[kCode] secret:state[kSecret] connected:connected error:state[kError]];
}
@end
