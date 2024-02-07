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

final class PlaylistParserTests: XCTestCase {
  func testParsing() throws {
    let parser = PlaylistParser(options: .removeSeriesInfoFromText)
    XCTAssertEqual(parser.options, .removeSeriesInfoFromText)

    let validURL = Bundle.module.url(forResource: "valid", withExtension: "m3u")!
    let playlist = try parser.parse(validURL)
    XCTAssertEqual(playlist.medias.count, 106)
    XCTAssertEqual(playlist.medias[0].name, "TV SHOW")
    XCTAssertEqual(playlist.medias[0].attributes.name, "TV SHOW")
    XCTAssertEqual(playlist.medias[0].attributes.seasonNumber, 1)
    XCTAssertEqual(playlist.medias[0].attributes.episodeNumber, 1)

    let invalidURL = Bundle.module.url(forResource: "invalid", withExtension: "m3u")!
    XCTAssertThrowsError(try parser.parse(invalidURL))
    XCTAssertThrowsError(try parser.parse(""))
    XCTAssertThrowsError(try parser.parse(InvalidSource()))
  }

	func testWalking() throws {
		let parser = PlaylistParser()
		var medias: [Playlist.Media] = []

		let exp = expectation(description: "Walking succeeded")
		let validURL = Bundle.module.url(forResource: "valid", withExtension: "m3u")!
		try parser.walk(validURL) { media in
			medias.append(media)
			if medias.count == 105 {
				exp.fulfill()
			}
		}

		waitForExpectations(timeout: 1)
		XCTAssertEqual(medias.count, 106)
	}

	func testWalkingInvalidSource() {
		let parser = PlaylistParser()
		XCTAssertThrowsError(try parser.walk("") { _ in })

		let invalidURL = Bundle.module.url(forResource: "invalid", withExtension: "m3u")!
		XCTAssertThrowsError(try parser.walk(invalidURL) { _ in })
	}


  func testErrorDescription() {
    let error1 = PlaylistParser.ParsingError.invalidSource
    XCTAssertEqual(error1.errorDescription, "The playlist is invalid")

    let error2 = PlaylistParser.ParsingError.missingDuration(3, "invalid line")
    XCTAssertEqual(
      error2.errorDescription,
      "Line 3: Missing duration in line \"invalid line\""
    )
  }

  func testParsingValidSourceWithACallback() {
    let parser = PlaylistParser()
    var medias: [Playlist.Media] = []

    let exp = expectation(description: "Parsing succeeded")
    let validURL = Bundle.module.url(forResource: "valid", withExtension: "m3u")!
    parser.parse(validURL) { result in
      switch result {
      case .success(let playlist):
        medias = playlist.medias
        exp.fulfill()
      case .failure:
        break
      }
    }

    waitForExpectations(timeout: 0.5)
    XCTAssertEqual(medias.count, 106)
  }

  func testParsingInvalidSourceWithACallback() {
    let parser = PlaylistParser()
    let exp = expectation(description: "Parsing failed")

    parser.parse("") { result in
      switch result {
      case .success:
        break
      case .failure:
        exp.fulfill()
      }
    }

    waitForExpectations(timeout: 0.5)
  }

  func testParsingMediaKind() {
    let parser = PlaylistParser()

    XCTAssertEqual(parser.parseMediaKind(URL(string: "test.com/movie/123456")!), .movie)
    XCTAssertEqual(parser.parseMediaKind(URL(string: "test.com/live/123456")!), .live)
    XCTAssertEqual(parser.parseMediaKind(URL(string: "test.com/series/123456")!), .series)
    XCTAssertEqual(parser.parseMediaKind(URL(string: "test.com/123456")!), .unknown)
  }

  func testExtractingDuration() throws {
    let parser = PlaylistParser()

    XCTAssertThrowsError(try parser.extractDuration(line: 1, rawString: "invalid"))
  }

  func testExtractingName() throws {
    let parser = PlaylistParser()

    XCTAssertEqual(parser.extractName("invalid"), "")
    XCTAssertEqual(parser.extractName(",valid"), "valid")
  }

  func testExtractingIdFromURL() {
    let parser = PlaylistParser()

    let url = URL(string: "https://domain.com/live/username/password/123456.mp4")!
    XCTAssertEqual(parser.extractId(url), "123456")
  }

  func testIsInfoLine() {
    let parser = PlaylistParser()

    XCTAssertTrue(parser.isInfoLine("#EXTINF:-1 tvg-id="))
    XCTAssertFalse(parser.isInfoLine("#EXTVLCOPT:http-user-agent"))
  }

  func testParsingAttributes() {
    let rawMedia = """
#EXTINF:-1 tvg-name="DWEnglish.de" tvg-id="DWEnglish.de" tvg-country="INT" tvg-language="English" tvg-logo="https://i.imgur.com/A1xzjOI.png" tvg-chno="1" tvg-shift="0" group-title="News",DW English (1080p)
"""
    let url = URL(string: "https://dwamdstream102.akamaized.net/hls/live/2015525/dwstream102/index.m3u8")!
    let parser = PlaylistParser(options: .extractIdFromURL)
    let attributes = parser.parseAttributes(rawString: rawMedia, url: url)
    XCTAssertEqual(attributes.name, "DWEnglish.de")
    XCTAssertEqual(attributes.id, "DWEnglish.de")
    XCTAssertEqual(attributes.country, "INT")
    XCTAssertEqual(attributes.language, "English")
    XCTAssertEqual(attributes.logo, "https://i.imgur.com/A1xzjOI.png")
    XCTAssertEqual(attributes.channelNumber, "1")
    XCTAssertEqual(attributes.shift, "0")
    XCTAssertEqual(attributes.groupTitle, "News")
  }

  func testParsingAttributesWithOverridingId() {
    let rawMedia = """
#EXTINF:-1 tvg-name="DWEnglish.de" tvg-id="" tvg-country="INT" tvg-language="English" tvg-logo="https://i.imgur.com/A1xzjOI.png" tvg-chno="1" tvg-shift="0" group-title="News",DW English (1080p)
"""
    let url = URL(string: "https://domain.com/live/username/password/123456.mp4")!
    let parser = PlaylistParser(options: .extractIdFromURL)
    let attributes = parser.parseAttributes(rawString: rawMedia, url: url)
    XCTAssertEqual(attributes.name, "DWEnglish.de")
    XCTAssertEqual(attributes.id, "123456")
    XCTAssertEqual(attributes.country, "INT")
    XCTAssertEqual(attributes.language, "English")
    XCTAssertEqual(attributes.logo, "https://i.imgur.com/A1xzjOI.png")
    XCTAssertEqual(attributes.channelNumber, "1")
    XCTAssertEqual(attributes.shift, "0")
    XCTAssertEqual(attributes.groupTitle, "News")
  }


  func testSeasonEpisodeParsing() {
    let parser = PlaylistParser()
    let input1 = "Kyou Kara Ore Wa!! LIVE ACTION S01 E09"
    let output1 = parser.parseSeasonEpisode(input1)
    XCTAssertEqual(output1.name, "Kyou Kara Ore Wa!! LIVE ACTION S01 E09")
    XCTAssertEqual(output1.se?.s, 1)
    XCTAssertEqual(output1.se?.e, 9)

    let input2 = "Kyou Kara Ore Wa!! LIVE ACTION S01E09"
    let output2 = parser.parseSeasonEpisode(input2)
    XCTAssertEqual(output2.name, "Kyou Kara Ore Wa!! LIVE ACTION S01E09")
    XCTAssertEqual(output2.se?.s, 1)
    XCTAssertEqual(output2.se?.e, 9)

    let input3 = "Kyou Kara Ore Wa!! LIVE ACTION s01e09"
    let output3 = parser.parseSeasonEpisode(input3)
    XCTAssertEqual(output3.name, "Kyou Kara Ore Wa!! LIVE ACTION s01e09")
    XCTAssertEqual(output3.se?.s, 1)
    XCTAssertEqual(output3.se?.e, 9)

    let input4 = "Kyou Kara Ore Wa!! LIVE ACTION s01 e09"
    let output4 = parser.parseSeasonEpisode(input4)
    XCTAssertEqual(output4.name, "Kyou Kara Ore Wa!! LIVE ACTION s01 e09")
    XCTAssertEqual(output4.se?.s, 1)
    XCTAssertEqual(output4.se?.e, 9)
  }

  func testSeasonEpisodeParsingWithNameUpdate() {
    let parser = PlaylistParser(options: .removeSeriesInfoFromText)
    let input = "Kyou Kara Ore Wa!! LIVE ACTION S01 E09"
    let output = parser.parseSeasonEpisode(input)
    XCTAssertEqual(output.name, "Kyou Kara Ore Wa!! LIVE ACTION")
    XCTAssertEqual(output.se?.s, 1)
    XCTAssertEqual(output.se?.e, 9)
  }

  @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
  func testAsyncAwaitParsing() async throws {
    let parser = PlaylistParser()

    let url = Bundle.module.url(forResource: "valid", withExtension: "m3u")!
    let playlist = try await parser.parse(url)
    XCTAssertEqual(playlist.medias.count, 106)
  }
}

private struct InvalidSource: PlaylistSource {
  var rawString: String? { nil }
}
