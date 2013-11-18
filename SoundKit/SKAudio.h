
#import "SKBus.h"

@interface SKAudio : NSObject <AVAudioSessionDelegate> {
    AUGraph processingGraph;
    BOOL playing;
    BOOL interruptedDuringPlayback;
    SKNU * mixerUnit;
    SKNU * ioUnit;
    NSMutableArray * buses;
}

@property (readwrite) AudioStreamBasicDescription stereoStreamFormat;
@property (readwrite) AudioStreamBasicDescription monoStreamFormat;
@property (getter = isPlaying) BOOL playing;
@property BOOL interruptedDuringPlayback;
@property (readonly) SKNU * mixer;
@property (readonly) SKNU * io;

- (void) configureAndInitializeAudioProcessingGraph;
- (void) startAUGraph;
- (void) stopAUGraph;

- (void) enableMixerInput: (UInt32) inputBus isOn: (AudioUnitParameterValue) isONValue;
- (void) setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) inputGain;
- (void) setMixerOutputGain: (AudioUnitParameterValue) outputGain;

- (SKBus*)busAt:(uint)i;

@end


