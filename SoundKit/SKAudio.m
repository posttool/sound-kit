

#import "SKAudio.h"


#pragma mark -
@implementation SKAudio

@synthesize mixerUnit;                  // the Multichannel Mixer unit
@synthesize mixerNode;      // node for Multichannel Mixer unit
@synthesize iONode;         // node for I/O unit

@synthesize playing;                    // Boolean flag to indicate whether audio is playing or not
@synthesize interruptedDuringPlayback;  // Boolean flag to indicate whether audio was playing when an interruption arrived

SKBus *t;

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
    
    
    NSURL *b0 = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HS Synthetic Electronic" ofType:@"sf2"]];
    t = [[SKBus alloc] init:b0];
    [t wire:processingGraph :mixerNode :0 :0];
    
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (processingGraph);
    
    [self startAUGraph];
    return self;
}



#pragma mark -
#pragma mark Audio processing graph setup

// This method performs all the work needed to set up the audio processing graph:

    // 1. Instantiate and open an audio processing graph
    // 2. Obtain the audio unit nodes for the graph
    // 3. Configure the Multichannel Mixer unit
    //     * specify the number of input buses
    //     * specify the output sample rate
    //     * specify the maximum frames-per-slice
    // 4. Initialize the audio processing graph

- (void) configureAndInitializeAudioProcessingGraph {

    NSLog (@"Configuring and then initializing audio processing graph");
    OSStatus result = noErr;

//............................................................................
// Create a new audio processing graph.
    result = NewAUGraph (&processingGraph);

    if (noErr != result) {[self printErrorMessage: @"NewAUGraph" withStatus: result]; return;}
    
    
//............................................................................
// Specify the audio unit component descriptions for the audio units to be
//    added to the graph.

    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    // Multichannel mixer unit
    AudioComponentDescription MixerUnitDescription;
    MixerUnitDescription.componentType          = kAudioUnitType_Mixer;
    MixerUnitDescription.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    MixerUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    MixerUnitDescription.componentFlags         = 0;
    MixerUnitDescription.componentFlagsMask     = 0;


//............................................................................
// Add nodes to the audio processing graph.
    NSLog (@"Adding nodes to audio processing graph");

    
    // Add the nodes to the audio processing graph
    result =    AUGraphAddNode (
                    processingGraph,
                    &iOUnitDescription,
                    &iONode);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNewNode failed for I/O unit" withStatus: result]; return;}
    

    result =    AUGraphAddNode (
                    processingGraph,
                    &MixerUnitDescription,
                    &mixerNode
                );

    if (noErr != result) {[self printErrorMessage: @"AUGraphNewNode failed for Mixer unit" withStatus: result]; return;}
    

//............................................................................
// Open the audio processing graph

    // Following this call, the audio units are instantiated but not initialized
    //    (no resource allocation occurs and the audio units are not in a state to
    //    process audio).
    result = AUGraphOpen (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphOpen" withStatus: result]; return;}
    
    
//............................................................................
// Obtain the mixer unit instance from its corresponding node.

    result =    AUGraphNodeInfo (
                    processingGraph,
                    mixerNode,
                    NULL,
                    &mixerUnit
                );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNodeInfo" withStatus: result]; return;}
    

//............................................................................
// Multichannel Mixer unit Setup

    UInt32 busCount   = 2;    // bus count for mixer unit input
    
    NSLog (@"Setting mixer unit input bus count to: %u", busCount);
    result = AudioUnitSetProperty (
                 mixerUnit,
                 kAudioUnitProperty_ElementCount,
                 kAudioUnitScope_Input,
                 0,
                 &busCount,
                 sizeof (busCount)
             );

    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit bus count)" withStatus: result]; return;}


    NSLog (@"Setting kAudioUnitProperty_MaximumFramesPerSlice for mixer unit global scope");
    // Increase the maximum frames per slice allows the mixer unit to accommodate the
    //    larger slice size used when the screen is locked.
    UInt32 maximumFramesPerSlice = 4096;
    
    result = AudioUnitSetProperty (
                 mixerUnit,
                 kAudioUnitProperty_MaximumFramesPerSlice,
                 kAudioUnitScope_Global,
                 0,
                 &maximumFramesPerSlice,
                 sizeof (maximumFramesPerSlice)
             );

    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit input stream format)" withStatus: result]; return;}



//............................................................................
// Connect the nodes of the audio processing graph
    NSLog (@"Connecting the mixer output to the input of the I/O unit output element");

    result = AUGraphConnectNodeInput (
                 processingGraph,
                 mixerNode,         // source node
                 0,                 // source node output bus number
                 iONode,            // destination node
                 0                  // desintation node input bus number
             );

    if (noErr != result) {[self printErrorMessage: @"AUGraphConnectNodeInput" withStatus: result]; return;}
    
    
//............................................................................
// Initialize audio processing graph

    // Diagnostic code
    // Call CAShow if you want to look at the state of the audio processing 
    //    graph.
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (processingGraph);

    NSLog (@"Initializing the audio processing graph");
    // Initialize the audio processing graph, configure audio data stream formats for
    //    each input and output, and validate the connections between audio units.
    result = AUGraphInitialize (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphInitialize" withStatus: result]; return;}
    
    
    
 

    
}


#pragma mark -
#pragma mark Playback control

// Start playback
- (void) startAUGraph  {

    NSLog (@"Starting audio processing graph");
    OSStatus result = AUGraphStart (processingGraph);
    if (noErr != result) {[self printErrorMessage: @"AUGraphStart" withStatus: result]; return;}

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
                         mixerUnit,
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

/*
    This method does *not* ensure that sound loops stay in sync if the user has 
    moved the volume of an input channel to zero. When a channel's input 
    level goes to zero, the corresponding input render callback is no longer 
    invoked. Consequently, the sample number for that channel remains constant 
    while the sample number for the other channel continues to increment. As a  
    workaround, the view controller Nib file specifies that the minimum input
    level is 0.01, not zero.
    
    The enableMixerInput:isOn: method in this class, however, does ensure that the 
    loops stay in sync when a user disables and then reenables an input bus.
*/
    OSStatus result = AudioUnitSetParameter (
                         mixerUnit,
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
                         mixerUnit,
                         kMultiChannelMixerParam_Volume,
                         kAudioUnitScope_Output,
                         0,
                         newGain,
                         0
                      );

    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (set mixer unit output volume)" withStatus: result]; return;}
    
}


///dork
- (void)playNoteOn:(UInt32)noteNum :(UInt32)velocity
{
    [t noteOn:noteNum :velocity];
}

- (void)playNoteOff:(UInt32)noteNum
{
    [t noteOff:noteNum];
}
-(SKBus*)bus
{
    return t;
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

