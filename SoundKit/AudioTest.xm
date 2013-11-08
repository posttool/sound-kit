//
//  AudioTest.m
//  FirstGame
//
//  Created by Ben Smiley-Andrews on 15/03/2012.
//  Copyright 2012 Deluge. All rights reserved.
//

#import "AudioTest.h"


#define kLowNote  48
#define kHighNote 72
#define kMidNote  60

@interface AudioTest ()

@property (readwrite) AUGraph   processingGraph;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;


@end

@implementation AudioTest


@synthesize processingGraph     = _processingGraph;
@synthesize samplerUnit         = _samplerUnit;
@synthesize ioUnit              = _ioUnit;


+ audioTest {
    return [[self alloc] initAudioTest];
}


-(id) initAudioTest {
	if((self = [self init] )) {

	}
	return self;
}

- (BOOL) createAUGraph {
    
    NewAUGraph (&_processingGraph);
    AUNode samplerNode, samplerNodeTwo, samplerNodeThree, ioNode, mixerNode;
    
    AudioComponentDescription cd = {};
    cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
    
    //----------------------------------------
    // Add 3 Sampler unit nodes to the graph
    //----------------------------------------
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    
    AUGraphAddNode (self.processingGraph, &cd, &samplerNode);
    AUGraphAddNode (self.processingGraph, &cd, &samplerNodeTwo);
    AUGraphAddNode (self.processingGraph, &cd, &samplerNodeThree);
    
    //-----------------------------------
    // 2. Add a Mixer unit node to the graph
    //-----------------------------------
    cd.componentType          = kAudioUnitType_Mixer;
    cd.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    
    AUGraphAddNode (self.processingGraph, &cd, &mixerNode);
    
    //--------------------------------------
    // 3. Add the Output unit node to the graph
    //--------------------------------------
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;  // Output to speakers
    
    AUGraphAddNode (self.processingGraph, &cd, &ioNode);
    
    //---------------
    // Open the graph
    //---------------
    AUGraphOpen (self.processingGraph);
    
    //-----------------------------------------------------------
    // Obtain the mixer unit instance from its corresponding node
    //-----------------------------------------------------------
    AUGraphNodeInfo (
                     self.processingGraph,
                     mixerNode,
                     NULL,
                     &mixerUnit
                     );
    
    //--------------------------------
    // Set the bus count for the mixer
    //--------------------------------
    UInt32 numBuses = 3;
    AudioUnitSetProperty(mixerUnit,
                         kAudioUnitProperty_ElementCount,
                         kAudioUnitScope_Input,
                         0,
                         &numBuses,
                         sizeof(numBuses));
    
    
    
    //------------------
    // Connect the nodes
    //------------------
    
    AUGraphConnectNodeInput (self.processingGraph, samplerNode, 0, mixerNode, 0);
    AUGraphConnectNodeInput (self.processingGraph, samplerNodeTwo, 0, mixerNode, 1);
    AUGraphConnectNodeInput (self.processingGraph, samplerNodeThree, 0, mixerNode, 2);
    
    // Connect the mixer unit to the output unit
    AUGraphConnectNodeInput (self.processingGraph, mixerNode, 0, ioNode, 0);
    
    // Obtain references to all of the audio units from their nodes
    AUGraphNodeInfo (self.processingGraph, samplerNode, 0, &_samplerUnit);
    AUGraphNodeInfo (self.processingGraph, samplerNodeTwo, 0, &_samplerUnitTwo);
    AUGraphNodeInfo (self.processingGraph, samplerNodeThree, 0, &_samplerUnitThree);
    AUGraphNodeInfo (self.processingGraph, ioNode, 0, &_ioUnit);
}



// this method assumes the class has a member called mySamplerUnit
// which is an instance of an AUSampler
-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withPatch: (int)presetNumber {

    OSStatus result = noErr;

    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) presetNumber;

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

    return result;
}

//-(void) load {
//    // Load the first instrument
//    AUSamplerBankPresetData bpdata;
//    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
//    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
//    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
//    bpdata.presetID = (UInt8) 0;
//    
//    AudioUnitSetProperty(self.samplerUnit,
//                         kAUSamplerProperty_LoadPresetFromBank,
//                         kAudioUnitScope_Global,
//                         0,
//                         &bpdata,
//                         sizeof(bpdata));
//    
//    // Load the second instrument
//    AUSamplerBankPresetData bpdataTwo;
//    bpdataTwo.bankURL  = (__bridge CFURLRef) bankURL;
//    bpdataTwo.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
//    bpdataTwo.bankLSB  = kAUSampler_DefaultBankLSB;
//    bpdataTwo.presetID = (UInt8) 1;
//    
//    AudioUnitSetProperty(self.samplerUnitTwo,
//                         kAUSamplerProperty_LoadPresetFromBank,
//                         kAudioUnitScope_Global,
//                         0,
//                         &bpdataTwo,
//                         sizeof(bpdataTwo));
//    
//    // Load the third instrument
//    AUSamplerBankPresetData bpdataThree;
//    bpdataThree.bankURL  = (__bridge CFURLRef) bankURL;
//    bpdataThree.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
//    bpdataThree.bankLSB  = kAUSampler_DefaultBankLSB;
//    bpdataThree.presetID = (UInt8) 2;
//    
//    AudioUnitSetProperty(self.samplerUnitThree,
//                         kAUSamplerProperty_LoadPresetFromBank,
//                         kAudioUnitScope_Global,
//                         0,
//                         &bpdataThree,
//                         sizeof(bpdataThree));
//}




// Starting with instantiated audio processing graph, configure its
// audio units, initialize it, and start it.
- (void) configureAndStartAudioProcessingGraph: (AUGraph) graph {
    
    OSStatus result = noErr;
    if (graph) {
        
        // Initialize the audio processing graph.
        result = AUGraphInitialize (graph);
        NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Start the graph
        result = AUGraphStart (graph);
        NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Print out the graph to the console
        //CAShow (graph);
    }
}

-(void)audio
{
    //-------------------------------------------------
    // Set the AUSampler nodes to be used by each track
    //-------------------------------------------------
    MusicTrack track, trackTwo, trackThree;
    MusicSequenceGetIndTrack(testSequence, 0, &track);
    MusicSequenceGetIndTrack(testSequence, 1, &trackTwo);
    MusicSequenceGetIndTrack(testSequence, 2, &trackThree);
    
    AUNode samplerNode, samplerNodeTwo, samplerNodeThree;
    AUGraphGetIndNode (self.processingGraph, 0, &samplerNode);
    AUGraphGetIndNode (self.processingGraph, 1, &samplerNodeTwo);
    AUGraphGetIndNode (self.processingGraph, 2, &samplerNodeThree);
    
    MusicTrackSetDestNode(track, samplerNode);
    MusicTrackSetDestNode(trackTwo, samplerNodeTwo);
    MusicTrackSetDestNode(trackThree, samplerNodeThree);
}


@end
