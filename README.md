
## Installation
    cordova plugin add https://github.com/distinctdan/cordova-plugin-play-audio.git
Tested platforms: Android 8+, iOS 11+
    
## Usage
This is a simple plugin designed to play background music for your app. Html5 audio is currently (2019-11-21) not good enough because of deal breaker bugs in iOS, such as playing audio at the wrong sample rate in iOS 12, or html audio tags being totally broken when used with an audio context in iOS 13. This plugin plays audio using native libraries to get around these issues. It uses heavier native classes, so it's more suited for background audio, and less suited for lots of small sound effects. Multiple songs can be played at the same time because each song uses a separate player.
    
### window.plugins.PlayAudio.playSong(songOptions, success?, error?)
Plays a single song. Runs asynchronously because songs can take a bit of time to load initially (~100ms). Once a song is loaded, its player is cached so future plays will be much faster.
```
const songOptions = {
    songId: string, // Unique string to identify this song.
    songURL?: string, // Relative path to song in your www directory.
    startOffset?: number, // Play start offset in seconds.
    volume?: number; // 0 to 1. Required if using fadeInLen.
    fadeInLen?: number, // Fade in length in seconds.
}
```
### window.plugins.PlayAudio.pauseSongs(songIds, success?, error?)
Pauses songs. On Android, you'll probably want to call this in an `onPause` callback to stop your app's audio. iOS auto-pauses and auto-resumes playing audio.

`songIds` is the array of the songIds you want to pause. Any songIds that haven't been played yet will be ignored.

### window.plugins.PlayAudio.setVolumes(volumeOptions, success?, error?)
Used to set the volume of multiple songs at once. Any songIds that haven't been played yet will be ignored.
```
const volumeOptions = [
    {songId: 'Song1', volume: 1},
    {songId: 'Song2', volume: 0},
];
```
### window.plugins.PlayAudio.registerForEvents(eventCallback?, error?)
Use this method to listen for events. Currently only the `SongEnded` event is supported. The callback will be called with the following object:
```
{
    eventName: 'SongEnded',
    songId: 'Song1',
}
```
