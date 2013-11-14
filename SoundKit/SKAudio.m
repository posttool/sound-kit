

#import "SKAudio.h"
#import "SKAudioError.h"
#import "SKNU.h"

#pragma mark -
@implementation SKAudio

@synthesize mixer;
@synthesize io;

@synthesize playing;                    // Boolean flag to indicate whether audio is playing or not
@synthesize interruptedDuringPlayback;  // Boolean flag to indicate whether audio was playing when an interruption arrived

;


- (id) init {

    self = [super init];
    
    if (!self) return nil;

    self.interruptedDuringPlayback = NO;

    [self configureAndInitializeAudioProcessingGraph];
    
    //     _____________
    //    /_ _ _ _ _ _ _\
    //    |_|_|_|_|_|_|__|
    //    |_ _ _ _ _ _ __|
    //    |_|_|_|_|_|_|__|
    //    |           |- |
    //    '-()--------()-'
    
    
//    t = [[SKBus alloc] init:@"HS Synthetic Electronic" :@"sf2"];
//    t = [[SKBus alloc] init:@"JK_Pads" :@"SF2"];
//    t = [[SKBus alloc] init:@"Johansson_BeautifulPad" :@"sf2"];
//    t = [[SKBus alloc] init:@"jonnypad6" :@"SF2"];
//    t = [[SKBus alloc] init:@"jonnypad8" :@"SF2"];
//    t = [[SKBus alloc] init:@"rtanpad1" :@"SF2"];
//    t = [[SKBus alloc] init:@"Vintage Dreams Waves v2" :@"sf2"];
//    t = [[SKBus alloc] init:@"hs-pad-texts" :@"sf2"];
//    t = [[SKBus alloc] init:@"tr808" :@"SF2"];
//    t = [[SKBus alloc] init:@"Gorts_Filters" :@"SF2"];
//    t = [[SKBus alloc] init:@"HS Synthetic Electronic" :@"sf2"];
//    t = [[SKBus alloc] init:@"synth" :@"sf2"];
//    t = [[SKBus alloc] init:@"mood" :@"sf2"];
    
    buses = [[NSMutableArray alloc] init];
    
    SKBus *t = [[SKBus alloc] init:@"Dark Basses" :@"sf2"];
    [t wire:processingGraph :mixer.node :0];
    [self setMixerInput:0 gain:.9];
    [buses addObject:t];

    t = [[SKBus alloc] init:@"2rock9" :@"sf2"];
    [t wire:processingGraph :mixer.node :1];
    [self setMixerInput:1 gain:.7];
    [buses addObject:t];


    NSLog (@"Audio processing graph state immediately before starting it:");
    CAShow (processingGraph);
    
    [self startAUGraph];
    return self;
}

-(SKBus*) busAt:(uint)i
{
    return [buses objectAtIndex:i];
}


#pragma mark -
#pragma mark Audio processing graph setup


- (void) configureAndInitializeAudioProcessingGraph
{

    NSLog (@"Configuring and then initializing audio processing graph");
    OSStatus result = noErr;

    //............................................................................
    // create a new audio processing graph.
    
    result = NewAUGraph (&processingGraph);
    [SKAudioError check:result :"new graph"];
    
    //............................................................................
    // io and mixer node s
    
    io = [[SKNU alloc] init:kAudioUnitType_Output :kAudioUnitSubType_RemoteIO];
    [io node:processingGraph];
    
    mixer = [[SKNU alloc] init:kAudioUnitType_Mixer :kAudioUnitSubType_MultiChannelMixer];
    [mixer node:processingGraph];

    //............................................................................
    // open the audio processing graph
    
    result = AUGraphOpen(processingGraph);
    [SKAudioError check:result :"open graph"];

    //............................................................................
    // add the mixer unit
    // btw, the api seems real fussy about adding the nodes, then opening the graph
    // ... then establishing the unit.
    
    [mixer unit:processingGraph];
    
    //............................................................................
    // set up the mixer properties
    
    [mixer setIntProp:kAudioUnitProperty_ElementCount :kAudioUnitScope_Input :2];
    [mixer setIntProp:kAudioUnitProperty_MaximumFramesPerSlice :kAudioUnitScope_Global :4096];

    //............................................................................
    // wire mixer to io

    [mixer wire:processingGraph :io.node];

    //............................................................................
    // initialize audio processing graph

    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (processingGraph);

    NSLog (@"Initializing the audio processing graph");
    result = AUGraphInitialize (processingGraph);
    [SKAudioError check:result :"AUGraphInitialize"];
    
    
}


//    if (WRITE_TO_DISK)
//    {
//        AURenderCallbackStruct callbackStruct = {0};
//        callbackStruct.inputProc = WriteToDiskAURenderCallback;
//        callbackStruct.inputProcRefCon = mixerUnit;
//
//        AudioUnitSetProperty(ioUnit,
//                             kAudioUnitProperty_SetRenderCallback,
//                             kAudioUnitScope_Input,
//                             0,
//                             &callbackStruct,
//                             sizeof(callbackStruct));
//    }


//OSStatus WriteToDiskAURenderCallback(void *inRefCon,
//                            AudioUnitRenderActionFlags *actionFlags,
//                            const AudioTimeStamp *inTimeStamp,
//                            UInt32 inBusNumber,
//                            UInt32 inNumberFrames,
//                            AudioBufferList *ioData) {
//    
//    AudioUnit mixerUnit = (AudioUnit)inRefCon;
//    
//    AudioUnitRender(mixerUnit,
//                    actionFlags,
//                    inTimeStamp,
//                    0,
//                    inNumberFrames,
//                    ioData);
//    
//    ExtAudioFileWriteAsync(outputFile,
//                           inNumberFrames,
//                           ioData);
//    
//    return noErr;
//}
//


#pragma mark -
#pragma mark Playback control

// Start playback
- (void) startAUGraph  {

    NSLog (@"Starting audio processing graph");
    OSStatus result = AUGraphStart (processingGraph);
    [SKAudioError check:result :"graph start"];

    self.playing = YES;
    

}

// Stop playback
- (void) stopAUGraph {

    NSLog (@"Stopping audio processing graph");
    Boolean isRunning = false;
    OSStatus result = AUGraphIsRunning (processingGraph, &isRunning);
    if (noErr != result) {[self printErrorMessage: @"AUGraphIsRunning" withStatus: result]; return;}
    
    if (isRunning) {
    
        result = AUGraphStop (processingGraph);
        if (noErr != result) {[self printErrorMessage: @"AUGraphStop" withStatus: result]; return;}
        self.playing = NO;
    }
}


#pragma mark -
#pragma mark Mixer unit control
// Enable or disable a specified bus
- (void) enableMixerInput: (UInt32) inputBus isOn: (AudioUnitParameterValue) isOnValue {

    NSLog (@"Bus %d now %@", (int) inputBus, isOnValue ? @"on" : @"off");
         
    OSStatus result = AudioUnitSetParameter (
                         mixer.unit,
                         kMultiChannelMixerParam_Enable,
                         kAudioUnitScope_Input,
                         inputBus,
                         isOnValue,
                         0
                      );

    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (enable the mixer unit)" withStatus: result]; return;}
    

}


// Set the mixer unit input volume for a specified bus
- (void) setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) newGain {


    OSStatus result = AudioUnitSetParameter (
                         mixer.unit,
                         kMultiChannelMixerParam_Volume,
                         kAudioUnitScope_Input,
                         inputBus,
                         newGain,
                         0
                      );

    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (set mixer unit input volume)" withStatus: result]; return;}
    
}


// Set the mxer unit output volume
- (void) setMixerOutputGain: (AudioUnitParameterValue) newGain {

    OSStatus result = AudioUnitSetParameter (
                         mixer.unit,
                         kMultiChannelMixerParam_Volume,
                         kAudioUnitScope_Output,
                         0,
                         newGain,
                         0
                      );

    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (set mixer unit output volume)" withStatus: result]; return;}
    
}






#pragma mark -
#pragma mark Audio Session Delegate Methods
// Respond to having been interrupted. This method sends a notification to the 
//    controller object, which in turn invokes the playOrStop: toggle method. The 
//    interruptedDuringPlayback flag lets the  endInterruptionWithFlags: method know 
//    whether playback was in progress at the time of the interruption.
//- (void) beginInterruption {
//
//    NSLog (@"Audio session was interrupted.");
//    
//    if (playing) {
//    
//        self.interruptedDuringPlayback = YES;
//        
//        NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
//        [[NSNotificationCenter defaultCenter] postNotificationName: MixerHostAudioObjectPlaybackStateDidChangeNotification object: self]; 
//    }
//}


// Respond to the end of an interruption. This method gets invoked, for example, 
//    after the user dismisses a clock alarm. 
//- (void) endInterruptionWithFlags: (NSUInteger) flags {
//
//    // Test if the interruption that has just ended was one from which this app 
//    //    should resume playback.
//    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
//
//        NSError *endInterruptionError = nil;
//        [[AVAudioSession sharedInstance] setActive: YES
//                                             error: &endInterruptionError];
//        if (endInterruptionError != nil) {
//        
//            NSLog (@"Unable to reactivate the audio session after the interruption ended.");
//            return;
//            
//        } else {
//        
//            NSLog (@"Audio session reactivated after interruption.");
//            
//            if (interruptedDuringPlayback) {
//            
//                self.interruptedDuringPlayback = NO;
//
//                // Resume playback by sending a notification to the controller object, which
//                //    in turn invokes the playOrStop: toggle method.
//                NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
//                [[NSNotificationCenter defaultCenter] postNotificationName: MixerHostAudioObjectPlaybackStateDidChangeNotification object: self]; 
//
//            }
//        }
//    }
//}


#pragma mark -
#pragma mark Utility methods

// You can use this method during development and debugging to look at the
//    fields of an AudioStreamBasicDescription struct.
//- (void) printASBD: (AudioStreamBasicDescription) asbd {
//
//    char formatIDString[5];
//    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
//    bcopy (&formatID, formatIDString, 4);
//    formatIDString[4] = '\0';
//    
//    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
//    NSLog (@"  Format ID:           %10s",    formatIDString);
//    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
//    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
//    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
//    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
//    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
//    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
//}


- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result {

    char resultString[5];
    UInt32 swappedResult = CFSwapInt32HostToBig (result);
    bcopy (&swappedResult, resultString, 4);
    resultString[4] = '\0';

    NSLog (
        @"*** %@ error: %d %08X %4.4s\n",
                errorString,
                (char*) &resultString
    );
}


@end

