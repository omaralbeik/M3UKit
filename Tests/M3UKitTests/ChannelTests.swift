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

final class ChannelTests: XCTestCase {
    func testInit() {
        let duration = 0
        let attributes = ChannelAttributes()
        let name = "name"
        let url = URL(string: "https://not.a/real/url")!

        let channel = Channel(
            duration: duration,
            attributes: attributes,
            name: name,
            url: url
        )

        XCTAssertEqual(channel.duration, duration)
        XCTAssertEqual(channel.attributes, attributes)
        XCTAssertEqual(channel.name, name)
        XCTAssertEqual(channel.url, url)
    }

    func testExtractingDuration() throws {
        let parser = ChannelParser()
        XCTAssertThrowsError(try parser.extractDuration("invalid"))
    }

    func testExtractingName() throws {
        let parser = ChannelParser()
        XCTAssertEqual(parser.extractName("invalid"), "")
        XCTAssertEqual(parser.extractName(",valid"), "valid")
    }
}
