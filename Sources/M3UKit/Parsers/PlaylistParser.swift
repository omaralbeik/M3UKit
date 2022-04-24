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
public final class PlaylistParser: Parser {
  enum ParsingError: LocalizedError {
    case invalidSource

    var errorDescription: String? {
      "The playlist is invalid"
    }
  }

  /// Create a new parser.
  public init() {}

  /// Parse a playlist.
  /// - Parameter input: source.
  /// - Returns: playlist.
  public func parse(_ input: PlaylistSource) throws -> Playlist {
    let rawString = try extractRawString(from: input)

    var channels: [Playlist.Channel] = []

    let metadataParser = ChannelMetadataParser()
    var lastMetadataLine: String?
    var lastURL: URL?
    var channelMetadataParsingError: Error?
    var lineNumber = 0

    rawString.enumerateLines { line, stop in
      if metadataParser.isInfoLine(line) {
        lastMetadataLine = line
      } else if let url = URL(string: line) {
        lastURL = url
      }

      if let metadataLine = lastMetadataLine, let url = lastURL {
        do {
          let metadata = try metadataParser.parse((lineNumber, metadataLine))
          channels.append(.init(metadata: metadata, url: url))
          lastMetadataLine = nil
          lastURL = nil
        } catch {
          channelMetadataParsingError = error
          stop = true
        }
      }

      lineNumber += 1
    }

    if let error = channelMetadataParsingError {
      throw error
    }

    return Playlist(channels: channels)
  }

  /// Walk over a playlist and return its channels one-by-one.
  /// - Parameters:
  ///   - input: source.
  ///   - handler: Handler to be called with the parsed channel.
  public func walk(
    _ input: PlaylistSource,
    handler: @escaping (Playlist.Channel) -> Void
  ) throws {
    let rawString = try extractRawString(from: input)

    let metadataParser = ChannelMetadataParser()
    var lastMetadataLine: String?
    var lastURL: URL?
    var channelMetadataParsingError: Error?
    var lineNumber = 0

    rawString.enumerateLines { line, stop in
      if metadataParser.isInfoLine(line) {
        lastMetadataLine = line
      } else if let url = URL(string: line) {
        lastURL = url
      }

      if let metadataLine = lastMetadataLine, let url = lastURL {
        do {
          let metadata = try metadataParser.parse((lineNumber, metadataLine))
          handler(.init(metadata: metadata, url: url))
          lastMetadataLine = nil
          lastURL = nil
        } catch {
          channelMetadataParsingError = error
          stop = true
        }
      }
      lineNumber += 1
    }

    if let error = channelMetadataParsingError {
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
    let processingTask = Task(priority: priority) { () -> Playlist in
      let playlist = try self.parse(input)
      return playlist
    }
    return try await processingTask.value
  }

  // MARK: - Helpers

  private func extractRawString(from input: PlaylistSource) throws -> String {
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
}
