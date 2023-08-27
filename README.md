# Tube

A iOS/macOS client for [Invidious](https://invidious.io), providing a native SwiftUI app for watching YouTube videos. 
It currently requires iOS 17+/macOS 14+, due to me wanting to try out `Observation` and `SwiftData`. 
Since it is just for my own personal use, backwards compatibility is not a concern – but I am willing to change that if 
there is interest.

> NOTE: This does bypass ads for creators due to the nature of Invidious. Please support creators you watch, via services like patreon, sponsorships, or direct donation links.

## Building

In the Config.xcconfig file, set the `INVIDIOUS_ORIGIN` property to the Invidious instance you want to use's origin 
(i.e. "example.com"):

```
INVIDIOUS_ORIGIN = example.com
```
