//
//  GDSoundEngine.m
//  SoundKit
//
//  Created by david karam on 11/6/13.
//  Copyright (c) 2013 david karam. All rights reserved.
//

#import "SKEngine.h"


#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "SKEngine.h"
#import "SKAudioError.h"

@interface SKEngine()

@property (readwrite) AUGraph processingGraph;
@property (readwrite) AUNode samplerNode;
@property (readwrite) AUNode ioNode;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;


@end

@implementation SKEngine

@synthesize playing = _playing;
@synthesize processingGraph = _processingGraph;
@synthesize samplerNode = _samplerNode;
@synthesize ioNode = _ioNode;
@synthesize ioUnit = _ioUnit;
@synthesize samplerUnit = _samplerUnit;

- (id) init
{
    if ( self = [super init] ) {
        [self createAUGraph];
        [self startGraph];
        NSURL *bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HS Synthetic Electronic" ofType:@"sf2"]];
//        NSURL *bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Vintage Dreams Waves v2" ofType:@"sf2"]];
//        NSURL *bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"hs-pad-texts" ofType:@"sf2"]];
//        NSURL *bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tr808" ofType:@"SF2"]];
//        NSURL *bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Gorts_Filters" ofType:@"SF2"]];
//        NSURL *bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Guitar18Mando16_ejl" ofType:@"sf2"]];
        OSStatus result = noErr;
        // fill out a bank preset data structure
        AUSamplerBankPresetData bpdata;
        bpdata.bankURL  = (__bridge CFURLRef) bankURL;
        bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
        bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
        bpdata.presetID = (UInt8) 0;
        
        // set the kAUSamplerProperty_LoadPresetFromBank property
        result = AudioUnitSetProperty(self.samplerUnit,
                                      kAUSamplerProperty_LoadPresetFromBank,
                                      kAudioUnitScope_Global,
                                      0,
                                      &bpdata,
                                      sizeof(bpdata));
        
        // check for errors
        NSCAssert (result == noErr,
                   @"Unable to set the preset property on the Sampler. Error code:%d '%.4s'",
                   (int) result,
                   (const char *)&result);
    }
    
    return self;
}

#pragma mark -
#pragma mark Audio setup
- (BOOL) createAUGraph
{
    NSLog(@"Creating the graph");
    
    CheckError(NewAUGraph(&_processingGraph), "NewAUGraph");
    
    // create the sampler
    // for now, just have it play the default sine tone
    AudioComponentDescription cd = {};
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    CheckError(AUGraphAddNode(self.processingGraph, &cd, &_samplerNode), "AUGraphAddNode");
    
    
    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    CheckError(AUGraphAddNode(self.processingGraph, &iOUnitDescription, &_ioNode), "AUGraphAddNode");
    
    // now do the wiring. The graph needs to be open before you call AUGraphNodeInfo
    CheckError(AUGraphOpen(self.processingGraph), "AUGraphOpen");
    
    CheckError(AUGraphNodeInfo(self.processingGraph, self.samplerNode, NULL, &_samplerUnit),
               "AUGraphNodeInfo");
    
    CheckError(AUGraphNodeInfo(self.processingGraph, self.ioNode, NULL, &_ioUnit),
               "AUGraphNodeInfo");
    
    AudioUnitElement ioUnitOutputElement = 0;
    AudioUnitElement samplerOutputElement = 0;
    CheckError(AUGraphConnectNodeInput(self.processingGraph,
                                       self.samplerNode, samplerOutputElement, // srcnode, inSourceOutputNumber
                                       self.ioNode, ioUnitOutputElement), // destnode, inDestInputNumber
               "AUGraphConnectNodeInput");
    
    
    NSLog (@"AUGraph is configured");
    CAShow(self.processingGraph);
    
    return YES;
}

- (void) startGraph
{
    if (self.processingGraph) {
        // this calls the AudioUnitInitialize function of each AU in the graph.
        // validates the graph's connections and audio data stream formats.
        // propagates stream formats across the connections
        Boolean outIsInitialized;
        CheckError(AUGraphIsInitialized(self.processingGraph,
                                        &outIsInitialized), "AUGraphIsInitialized");
        if(!outIsInitialized)
            CheckError(AUGraphInitialize(self.processingGraph), "AUGraphInitialize");
        
        Boolean isRunning;
        CheckError(AUGraphIsRunning(self.processingGraph,
                                    &isRunning), "AUGraphIsRunning");
        if(!isRunning)
            CheckError(AUGraphStart(self.processingGraph), "AUGraphStart");
        self.playing = YES;
    }
}
- (void) stopAUGraph {
    
    NSLog (@"Stopping audio processing graph");
    Boolean isRunning = false;
    CheckError(AUGraphIsRunning (self.processingGraph, &isRunning), "AUGraphIsRunning");
    
    if (isRunning) {
        CheckError(AUGraphStop(self.processingGraph), "AUGraphStop");
        self.playing = NO;
    }
}

#pragma mark -
#pragma mark Audio control
- (void)playNoteOn:(UInt32)noteNum :(UInt32)velocity
{
    UInt32 noteCommand = 0x90 | 0;
//    NSLog(@"playNoteOn %lu %lu cmd %lx", noteNum, velocity, noteCommand);
    CheckError(MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, velocity, 0), "NoteOn");
}

- (void)playNoteOff:(UInt32)noteNum
{
    UInt32 noteCommand = 0x80 | 0;
    CheckError(MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, 0, 0), "NoteOff");
}

//



void CheckError(OSStatus error, const char *operation)
{
    [SKAudioError check:error :operation];
}
@end




