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

import Foundation

final class ChannelParser: Parser {
  enum ParsingError: LocalizedError {
    case invalidChannel
  }

  func parse(_ input: (metadata: String, url: URL)) throws -> Playlist.Channel {
    let duration = try extractDuration(input.metadata)
    let attributes = try attributesParser.parse(input.metadata)
    let name = extractName(input.metadata)
    let url = input.url

    return .init(
      duration: duration,
      attributes: attributes,
      name: name,
      url: url
    )
  }

  func extractDuration(_ metadata: String) throws -> Int {
    guard
      let match = durationRegex.firstMatch(in: metadata),
      let duration = Int(match)
    else {
      throw ParsingError.invalidChannel
    }
    return duration
  }

  func extractName(_ metadata: String) -> String {
    return nameRegex.firstMatch(in: metadata) ?? ""
  }

  let attributesParser = ChannelAttributesParser()
  let durationRegex: RegularExpression = #"#EXTINF:(\-*\d+)"#
  let nameRegex: RegularExpression = #".*,(.+?)$"#
}
