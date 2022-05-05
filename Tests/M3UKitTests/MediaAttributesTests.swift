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

final class MediaAttributesTests: XCTestCase {
  func testInit() {
    let id = "id"
    let name = "name"
    let country = "country"
    let language = "language"
    let logo = "logo"
    let channelNumber = "channelNumber"
    let shift = "shift"
    let groupTitle = "groupTitle"
    let seasonNumber = 1
    let episodeNumber = 5

    let attributes = Playlist.Media.Attributes(
      id: id,
      name: name,
      country: country,
      language: language,
      logo: logo,
      channelNumber: channelNumber,
      shift: shift,
      groupTitle: groupTitle,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber
    )

    XCTAssertEqual(attributes.id, id)
    XCTAssertEqual(attributes.name, name)
    XCTAssertEqual(attributes.country, country)
    XCTAssertEqual(attributes.language, language)
    XCTAssertEqual(attributes.logo, logo)
    XCTAssertEqual(attributes.channelNumber, channelNumber)
    XCTAssertEqual(attributes.shift, shift)
    XCTAssertEqual(attributes.groupTitle, groupTitle)
    XCTAssertEqual(attributes.seasonNumber, seasonNumber)
    XCTAssertEqual(attributes.episodeNumber, episodeNumber)
  }

  func testParsing() throws {
    let rawMedia = """
#EXTINF:-1 tvg-name="DWEnglish.de" tvg-id="DWEnglish.de" tvg-country="INT" tvg-language="English" tvg-logo="https://i.imgur.com/A1xzjOI.png" tvg-chno="1" tvg-shift="0" group-title="News",DW English (1080p)
https://dwamdstream102.akamaized.net/hls/live/2015525/dwstream102/index.m3u8
"""
    let parser = MediaAttributesParser()
    let attributes = try parser.parse(rawMedia)
    XCTAssertEqual(attributes.name, "DWEnglish.de")
    XCTAssertEqual(attributes.id, "DWEnglish.de")
    XCTAssertEqual(attributes.country, "INT")
    XCTAssertEqual(attributes.language, "English")
    XCTAssertEqual(attributes.logo, "https://i.imgur.com/A1xzjOI.png")
    XCTAssertEqual(attributes.channelNumber, "1")
    XCTAssertEqual(attributes.shift, "0")
    XCTAssertEqual(attributes.groupTitle, "News")
  }

  func testSeasonEpisodeParsing() throws {
    let parser = SeasonEpisodeParser()
    let input = "Kyou Kara Ore Wa!! LIVE ACTION S01 E09"
    let output = try parser.parse(input)
    XCTAssertEqual(output.name, "Kyou Kara Ore Wa!! LIVE ACTION")
    XCTAssertEqual(output.se?.s, 1)
    XCTAssertEqual(output.se?.e, 9)
  }
}
