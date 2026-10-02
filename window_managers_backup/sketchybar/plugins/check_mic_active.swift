import CoreAudio
import Foundation

func isInputDeviceRunning() -> Bool {
    var defaultDeviceID = AudioObjectID(kAudioObjectUnknown)
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var size = UInt32(MemoryLayout<AudioObjectID>.size)
    
    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &size,
        &defaultDeviceID
    )
    
    guard status == noErr, defaultDeviceID != kAudioObjectUnknown else {
        return false
    }
    
    var isRunning: UInt32 = 0
    propertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(0x676c6f62), // 'glob' = kAudioDevicePropertyDeviceIsRunningSomewhere
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    size = UInt32(MemoryLayout<UInt32>.size)
    
    let runningStatus = AudioObjectGetPropertyData(
        defaultDeviceID,
        &propertyAddress,
        0,
        nil,
        &size,
        &isRunning
    )
    
    return runningStatus == noErr && isRunning != 0
}

if isInputDeviceRunning() {
    print("running")
    exit(0)
} else {
    print("idle")
    exit(1)
}
