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

internal struct RegularExpression {
  internal let regex: NSRegularExpression

  internal init(_ regex: NSRegularExpression) {
    self.regex = regex
  }

  internal func numberOfMatches(source: String) -> Int {
    let sourceRange = NSRange(source.startIndex..<source.endIndex, in: source)
    return regex.numberOfMatches(in: source, range: sourceRange)
  }

  internal func firstMatch(in source: String) -> String? {
    let sourceRange = NSRange(source.startIndex..<source.endIndex, in: source)
    guard
      let match = regex.firstMatch(in: source, range: sourceRange),
      let range = Range(match.range(at: 1), in: source)
    else {
      return nil
    }
    return String(source[range])
  }

  internal func matchingRanges(in source: String) -> [Range<String.Index>] {
    let sourceRange = NSRange(source.startIndex..<source.endIndex, in: source)
    guard let match = regex.firstMatch(in: source, range: sourceRange) else {
      return []
    }
    return (0..<match.numberOfRanges)
      .compactMap {
        match.range(at: $0)
      }
      .compactMap {
        Range($0, in: source)
      }
  }
}

extension RegularExpression: ExpressibleByStringLiteral {
  internal init(stringLiteral value: String) {
    let regex = try! NSRegularExpression(pattern: value, options: [])
    self.init(regex)
  }
}
