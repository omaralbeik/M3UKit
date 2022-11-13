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

final class MediaKindParser: Parser {
  func parse(_ input: URL) -> Playlist.Media.Kind {
    let string = input.absoluteString
    if seriesRegex.numberOfMatches(source: string) == 1 {
      return .series
    }
    if moviesRegex.numberOfMatches(source: string) == 1 {
      return .movie
    }
    if liveRegex.numberOfMatches(source: string) == 1 {
      return .live
    }
    return .unknown
  }

  let moviesRegex: RegularExpression = #"\/movies\/"#
  let seriesRegex: RegularExpression = #"\/series\/"#
  let liveRegex: RegularExpression = #"\/live\/"#
}
