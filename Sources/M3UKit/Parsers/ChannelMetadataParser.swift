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

final class ChannelMetadataParser: Parser {
  enum ParsingError: LocalizedError {
    case missingDuration(Int, String)

    var errorDescription: String? {
      switch self {
      case .missingDuration(let lineNumber, let rawString):
        return "Line \(lineNumber): Missing duration in line \"\(rawString)\""
      }
    }
  }

  func parse(_ input: (line: Int, rawString: String)) throws -> Playlist.Channel.Metadata {
    let duration = try extractDuration(input)
    let attributes = try attributesParser.parse(input.rawString)
    let name = extractName(input.rawString)
    return (duration, attributes, name)
  }

  func isInfoLine(_ input: String) -> Bool {
    return input.starts(with: "#EXTINF:")
  }

  func extractDuration(_ input: (line: Int, rawString: String)) throws -> Int {
    guard
      let match = durationRegex.firstMatch(in: input.rawString),
      let duration = Int(match)
    else {
      throw ParsingError.missingDuration(input.line, input.rawString)
    }
    return duration
  }

  func extractName(_ input: String) -> String {
    return nameRegex.firstMatch(in: input) ?? ""
  }

  let attributesParser = ChannelAttributesParser()
  let durationRegex: RegularExpression = #"#EXTINF:(\-*\d+)"#
  let nameRegex: RegularExpression = #".*,(.+?)$"#
}
