#import "PlayAudio.h"

@implementation PlayAudio

NSMutableDictionary* players;

- (void)pluginInitialize
{
    players = [[NSMutableDictionary alloc] init];
}

- (void)dealloc
{

}

- (void)playSong:(CDVInvokedUrlCommand*)command
{
    @try {
        NSError* err;
        NSDictionary* props = command.arguments[0];
        NSString* songId = props[@"songId"];
        NSString* songURL = props[@"songURL"];
        double offsetSecs = props[@"startOffset"] ? [props[@"startOffset"] doubleValue] : 0;
        float vol = props[@"volume"] ? [props[@"volume"] floatValue] : 1;
        float fadeInLen = props[@"fadeInLen"] ? [props[@"fadeInLen"] floatValue] : 0;
        float fadeOutLen = props[@"fadeOutLen"] ? [props[@"fadeOutLen"] floatValue] : 0;

        // Create player for this song if we haven't already
        if (!players[songId]) {
            NSString* basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
            NSString* pathFromWWW = [NSString stringWithFormat:@"%@/%@", basePath, songURL];

            if ([[NSFileManager defaultManager] fileExistsAtPath : pathFromWWW]) {
                NSURL *pathURL = [NSURL fileURLWithPath : pathFromWWW];
                players[songId] = [[AVAudioPlayer alloc] initWithContentsOfURL:pathURL error:&err];

                if (err) {
                    NSString* msg = [NSString stringWithFormat:@"Player init error: %ld - %@", (long)err.code, err.description];
                    [self onErrorWithMethodName:@"playSong" msg:msg  callbackId:command.callbackId];
                    return;
                }
            } else {
                NSString* msg = [NSString stringWithFormat:@"Song not found at path: %@", pathFromWWW];
                [self onErrorWithMethodName:@"playSong" msg:msg callbackId:command.callbackId];
                return;
            }
        }

        AVAudioPlayer* player = players[songId];
        player.volume = 0;
        [player setVolume:vol fadeDuration:fadeInLen];
        [player setDelegate:self];
        bool success = [player playAtTime:offsetSecs];
        if (success) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            [self onErrorWithMethodName:@"playSong" msg:@"playing failed" callbackId:command.callbackId];
            return;
        }
    } @catch (NSException *exception) {
       [self onErrorWithMethodName:@"playSong" exception:exception callbackId:command.callbackId];
   }
}

- (void)pauseSongs:(CDVInvokedUrlCommand*)command
{
    @try {

    } @catch (NSException *exception) {
       [self onErrorWithMethodName:@"pauseSongs" exception:exception callbackId:command.callbackId];
   }
}

- (void)setVolumes:(CDVInvokedUrlCommand*)command
{
    @try {

    } @catch (NSException *exception) {
       [self onErrorWithMethodName:@"setVolumes" exception:exception callbackId:command.callbackId];
   }
}

- (void)registerForEvents:(CDVInvokedUrlCommand*)command
{
    @try {

    } @catch (NSException *exception) {
        [self onErrorWithMethodName:@"registerForEvents" exception:exception callbackId:command.callbackId];
   }
}

// ----------------------------------------------------
//                  Delegate Methods
// ----------------------------------------------------
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)success
{
    NSLog(@"TEMP - audio finished. Success: %d", success);
}

// ----------------------------------------------------
//                  Error Handling
// ----------------------------------------------------
- (void) onErrorWithMethodName:(NSString*)method
                     exception:(NSException*)e
                    callbackId:(NSString*)callbackId
{
    NSString* msg = [NSString stringWithFormat:@"%@ - %@", e.name, e.reason];
    [self onErrorWithMethodName:method msg:msg callbackId:callbackId];
}

- (void) onErrorWithMethodName:(NSString*)method
                           msg:(NSString*)msg
                    callbackId:(NSString*)callbackId
{
    NSString* err = [NSString stringWithFormat:@"PlayAudio - %@ ERROR: %@", method, msg];
    NSLog(@"%@", err);

    if (callbackId) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:err];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

@end
