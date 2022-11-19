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

/// A class to parse `Playlist` objects from a `PlaylistSource`.
public final class PlaylistParser {

  /// Playlist parser options
  public struct Options: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    /// Remove season number and episode number "S--E--" from the name of media.
    public static let removeSeriesInfoFromText = Options(rawValue: 1 << 0)

    /// Extract id from the URL (usually last path component removing the extension)
    public static let extractIdFromURL = Options(rawValue: 1 << 1)

    /// All available options.
    public static let all: Options = [
      .removeSeriesInfoFromText,
      .extractIdFromURL,
    ]
  }

  /// Parser options.
  public let options: Options

  /// Create a new parser.
  /// - Parameter options: Parser options, defaults to .all
  public init(options: Options = []) {
    self.options = options
  }

  /// Parse a playlist.
  /// - Parameter input: source.
  /// - Returns: playlist.
  public func parse(_ input: PlaylistSource) throws -> Playlist {
    let rawString = try extractRawString(from: input)

    var medias: [Playlist.Media] = []

    var lastMetadataLine: String?
    var lastURL: URL?
    var mediaMetadataParsingError: Error?
    var lineNumber = 0

    rawString.enumerateLines { [weak self] line, stop in
      guard let self else {
        stop = true
        return
      }

      if self.isInfoLine(line) {
        lastMetadataLine = line
      } else if let url = URL(string: line) {
        lastURL = url
      }

      if let metadataLine = lastMetadataLine, let url = lastURL {
        do {
          let metadata = try self.parseMetadata(line: lineNumber, rawString: metadataLine, url: url)
          let kind = self.parseMediaKind(url)
          medias.append(.init(metadata: metadata, kind: kind, url: url))
          lastMetadataLine = nil
          lastURL = nil
        } catch {
          mediaMetadataParsingError = error
          stop = true
        }
      }

      lineNumber += 1
    }

    if let error = mediaMetadataParsingError {
      throw error
    }

    return Playlist(medias: medias)
  }

  /// Walk over a playlist and return its medias one-by-one.
  /// - Parameters:
  ///   - input: source.
  ///   - handler: Handler to be called with the parsed medias.
  public func walk(
    _ input: PlaylistSource,
    handler: @escaping (Playlist.Media) -> Void
  ) throws {
    let rawString = try extractRawString(from: input)

    var lastMetadataLine: String?
    var lastURL: URL?
    var mediaMetadataParsingError: Error?
    var lineNumber = 0

    rawString.enumerateLines { [weak self] line, stop in
      guard let self else {
        stop = true
        return
      }

      if self.isInfoLine(line) {
        lastMetadataLine = line
      } else if let url = URL(string: line) {
        lastURL = url
      }

      if let metadataLine = lastMetadataLine, let url = lastURL {
        do {
          let metadata = try self.parseMetadata(line: lineNumber, rawString: metadataLine, url: url)
          let kind = self.parseMediaKind(url)
          handler(.init(metadata: metadata, kind: kind, url: url))
          lastMetadataLine = nil
          lastURL = nil
        } catch {
          mediaMetadataParsingError = error
          stop = true
        }
      }
      lineNumber += 1
    }

    if let error = mediaMetadataParsingError {
      throw error
    }
  }

  /// Parse a playlist on a queue with a completion handler.
  /// - Parameters:
  ///   - input: source.
  ///   - processingQueue: queue to perform parsing on. Defaults to `.global(qos: .background)`
  ///   - callbackQueue: queue to call callback on. Defaults to `.main`
  ///   - completion: completion handler to call with the result.
  public func parse(
    _ input: PlaylistSource,
    processingQueue: DispatchQueue = .global(qos: .background),
    callbackQueue: DispatchQueue = .main,
    completion: @escaping (Result<Playlist, Error>) -> Void
  ) {
    processingQueue.async {
      do {
        let playlist = try self.parse(input)
        callbackQueue.async {
          completion(.success(playlist))
        }
      } catch {
        callbackQueue.async {
          completion(.failure(error))
        }
      }
    }
  }

  @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
  /// Parse a playlist.
  /// - Parameter input: source.
  /// - Parameter priority: Processing task priority. Defaults to `.background`
  /// - Returns: playlist.
  public func parse(
    _ input: PlaylistSource,
    priority: TaskPriority = .background
  ) async throws -> Playlist {
    let processingTask = Task(priority: priority) {
      try self.parse(input)
    }
    return try await processingTask.value
  }

  // MARK: - Helpers

  internal func extractRawString(from input: PlaylistSource) throws -> String {
    let filePrefix = "#EXTM3U"
    guard var rawString = input.rawString else {
      throw ParsingError.invalidSource
    }
    guard rawString.starts(with: filePrefix) else {
      throw ParsingError.invalidSource
    }
    rawString.removeFirst(filePrefix.count)
    return rawString
  }

  internal enum ParsingError: LocalizedError {
    case invalidSource
    case missingDuration(Int, String)

    internal var errorDescription: String? {
      switch self {
      case .invalidSource:
        return "The playlist is invalid"
      case .missingDuration(let line, let raw):
        return "Line \(line): Missing duration in line \"\(raw)\""
      }
    }
  }

  internal typealias Show = (name: String, se: (s: Int, e: Int)?)

  internal func parseMetadata(line: Int, rawString: String, url: URL) throws -> Playlist.Media.Metadata {
    let duration = try extractDuration(line: line, rawString: rawString)
    let attributes = parseAttributes(rawString: rawString, url: url)
    let name = parseSeasonEpisode(extractName(rawString)).name
    return (duration, attributes, name)
  }

  internal func isInfoLine(_ input: String) -> Bool {
    return input.starts(with: "#EXTINF:")
  }

  internal func extractDuration(line: Int, rawString: String) throws -> Int {
    guard
      let match = durationRegex.firstMatch(in: rawString),
      let duration = Int(match)
    else {
      throw ParsingError.missingDuration(line, rawString)
    }
    return duration
  }

  internal func extractName(_ input: String) -> String {
    return nameRegex.firstMatch(in: input) ?? ""
  }

  internal func extractId(_ input: URL) -> String {
    String(input.lastPathComponent.split(separator: ".").first ?? "")
  }

  internal func parseMediaKind(_ input: URL) -> Playlist.Media.Kind {
    let string = input.absoluteString
    if mediaKindMSeriesRegex.numberOfMatches(source: string) == 1 {
      return .series
    }
    if mediaKindMoviesRegex.numberOfMatches(source: string) == 1 {
      return .movie
    }
    if mediaKindMLiveRegex.numberOfMatches(source: string) == 1 {
      return .live
    }
    return .unknown
  }

  internal func parseAttributes(rawString: String, url: URL) -> Playlist.Media.Attributes {
    var attributes = Playlist.Media.Attributes()
    let id = attributesIdRegex.firstMatch(in: rawString) ?? ""
    attributes.id = id
    if id.isEmpty && options.contains(.extractIdFromURL) {
      attributes.id = extractId(url)
    }
    if let name = attributesNameRegex.firstMatch(in: rawString) {
      let show = parseSeasonEpisode(name)
      attributes.name = show.name
      attributes.seasonNumber = show.se?.s
      attributes.episodeNumber = show.se?.e
    }
    if let country = attributesCountryRegex.firstMatch(in: rawString) {
      attributes.country = country
    }
    if let language = attributesLanguageRegex.firstMatch(in: rawString) {
      attributes.language = language
    }
    if let logo = attributesLogoRegex.firstMatch(in: rawString) {
      attributes.logo = logo
    }
    if let channelNumber = attributesChannelNumberRegex.firstMatch(in: rawString) {
      attributes.channelNumber = channelNumber
    }
    if let shift = attributesShiftRegex.firstMatch(in: rawString) {
      attributes.shift = shift
    }
    if let groupTitle = attributesGroupTitleRegex.firstMatch(in: rawString) {
      attributes.groupTitle = groupTitle
    }
    return attributes
  }

  internal func parseSeasonEpisode(_ input: String) -> Show {
    let ranges = seasonEpisodeRegex.matchingRanges(in: input)
    guard
      ranges.count == 3,
      let s = Int(input[ranges[1]]),
      let e = Int(input[ranges[2]])
    else {
      return (name: input, se: nil)
    }
    var name = input
    if options.contains(.removeSeriesInfoFromText) {
      name.removeSubrange(ranges[0])
    }
    return (name: name, se: (s, e))
  }

  // MARK: - Regex

  internal let durationRegex: RegularExpression = #"#EXTINF:(\-*\d+)"#
  internal let nameRegex: RegularExpression = #".*,(.+?)$"#

  internal let mediaKindMoviesRegex: RegularExpression = #"\/movies\/"#
  internal let mediaKindMSeriesRegex: RegularExpression = #"\/series\/"#
  internal let mediaKindMLiveRegex: RegularExpression = #"\/live\/"#

  internal let seasonEpisodeRegex: RegularExpression = #" S(\d+) E(\d+)"#

  internal let attributesIdRegex: RegularExpression = #"tvg-id=\"(.?|.+?)\""#
  internal let attributesNameRegex: RegularExpression = #"tvg-name=\"(.?|.+?)\""#
  internal let attributesCountryRegex: RegularExpression = #"tvg-country=\"(.?|.+?)\""#
  internal let attributesLanguageRegex: RegularExpression = #"tvg-language=\"(.?|.+?)\""#
  internal let attributesLogoRegex: RegularExpression = #"tvg-logo=\"(.?|.+?)\""#
  internal let attributesChannelNumberRegex: RegularExpression = #"tvg-chno=\"(.?|.+?)\""#
  internal let attributesShiftRegex: RegularExpression = #"tvg-shift=\"(.?|.+?)\""#
  internal let attributesGroupTitleRegex: RegularExpression = #"group-title=\"(.?|.+?)\""#
}
