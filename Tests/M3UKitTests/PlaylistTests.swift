//
// M3UKit
//
// Copyright (c) 2022 Omar Albeik
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
@testable import M3UKit

final class PlaylistTests: XCTestCase {
  func testInit() {
    XCTAssert(Playlist(channels: []).channels.isEmpty)
  }

  func testParsing() throws {
    let parser = PlaylistParser()

    let validURL = Bundle.module.url(forResource: "valid", withExtension: "m3u")!
    let playlist = try parser.parse(validURL)
    XCTAssertEqual(playlist.channels.count, 105)

    let invalidURL = Bundle.module.url(forResource: "invalid", withExtension: "m3u")!
    XCTAssertThrowsError(try parser.parse(invalidURL))
    XCTAssertThrowsError(try parser.parse(""))
    XCTAssertThrowsError(try parser.parse(InvalidSource()))
  }
}

private struct InvalidSource: PlaylistSource {
  var rawString: String? { nil }
}
