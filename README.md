# M3UKit

Modern framework for parsing [m3u](https://en.wikipedia.org/wiki/M3U) files.

[![CI](https://github.com/omaralbeik/M3UKit/workflows/M3UKit/badge.svg)](https://github.com/omaralbeik/M3UKit/actions)
[![codecov](https://codecov.io/gh/omaralbeik/M3UKit/branch/main/graph/badge.svg?token=W42K82OT7M)](https://codecov.io/gh/omaralbeik/M3UKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fomaralbeik%2FM3UKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/omaralbeik/M3UKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fomaralbeik%2FM3UKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/omaralbeik/M3UKit)

---

## Features

- [x] Parse playlists from a `String`, local file, or any URL.
- [x] Capable of parsing large playlists with hundreds of thousands of media items.
- [x] Sync/Async parsing.
- [x] Season/Episode number extraction for TV show media items.
- [x] Media kind extraction from URL path.

## Usage

### 1. Create a parser

```swift
let parser = PlaylistParser()
```

### 2. Parse a playlist

The playlist parser can parse a playlist from any source that conforms to the protocol `PlaylistSource`, by default: `String`, and `URL`.

```swift
let url = URL(string: "https://domain.com/link/to/m3u/file")
let playlist = try parser.parse(url)
```

or

```swift
let url = Bundle.main.url(forResource: "playlist", withExtension: "m3u")!
let playlist = try parser.parse(url)
```

or

```swift
let raw = """
#EXTM3U
#EXTINF:-1 tvg-id="DenHaagTV.nl",Den Haag TV (1080p)
http://wowza5.video-streams.nl:1935/denhaag/denhaag/playlist.m3u8
"""
let playlist = try parser.parse(raw)
```

M3UKit also supports asynchronous parsing with a completion handler or with the new async/await API

```swift
parser.parse(url) { result in
    switch result {
    case .success(let playlist):
        // consume playlist
    case .failure(let error):
        // handle error
    }
}
```

or

```swift
let playlist = try await parser.parse(url)
```

---

## Schema

M3U exposes one model; `Playlist`, with the following schema:

```
Playlist
└── medias
```

```
Media
├── duration
├── attributes
├── kind
├── name
└── url
```

```
Attributes
├── id (tvg-id)
├── name (tvg-name)
├── country (tvg-country)
├── language (tvg-language)
├── logo (tvg-logo)
├── channelNumber (tvg-chno)
├── shift (tvg-shift)
├── groupTitle (group-title)
├── seasonNumber
└── episodeNumber
```

```
Kind
├── movie
├── series
├── live
└── unknown
```

---

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code.

1. Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/omaralbeik/M3UKit.git", from: "0.8.0")
]
```

2. Build your project:

```sh
$ swift build
```

### CocoaPods

To integrate M3UKit into your Xcode project using [CocoaPods](https://cocoapods.org), specify it in your Podfile:

```rb
pod 'M3UKit', :git => 'https://github.com/omaralbeik/M3UKit.git', :tag => '0.8.0'
```

### Carthage

To integrate M3UKit into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your Cartfile:

```
github "omaralbeik/M3UKit" ~> 0.8.0
```

### Manually

Add the [Sources](https://github.com/omaralbeik/M3UKit/tree/main/Sources) folder to your Xcode project.

---

## Thanks

Special thanks to [Bashar Ghadanfar](https://github.com/lionbytes) for helping with the regex patterns used for parsing m3u files 👏

---

## License

M3UKit is released under the MIT license. See [LICENSE](https://github.com/omaralbeik/M3UKit/blob/main/LICENSE) for more information.
