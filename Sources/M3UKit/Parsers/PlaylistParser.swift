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
  }

  /// Create a new parser.
  public init() {}

  /// Parse a playlist.
  /// - Parameter input: source.
  /// - Returns: playlist.
  public func parse(_ input: PlaylistSource) throws -> Playlist {
    guard let rawString = input.rawString else {
      throw ParsingError.invalidSource
    }

    guard rawString.starts(with: "#EXTM3U") else {
      throw ParsingError.invalidSource
    }

    let channelParser = ChannelParser()

    var channels: [Playlist.Channel] = []
    var channelParsingError: Error?
    var lastMetadata: String?

    rawString.enumerateLines { line, stop in
      if let url = URL(string: line) {
        guard let metadata = lastMetadata else { return }
        do {
          let channel = try channelParser.parse((metadata, url))
          channels.append(channel)
        } catch {
          channelParsingError = error
          stop = true
        }
      } else {
        lastMetadata = line
      }
    }

    if let error = channelParsingError {
      throw error
    }

    return Playlist(channels: channels)
  }

  /// Parse a playlist on a queue with a completion handler.
  /// - Parameters:
  ///   - input: source.
  ///   - queue: queue to perform parsing on. Defaults to `.global(qos: .userInitiated)`
  ///   - completion: completion handler to call with the result.
  public func parse(
    _ input: PlaylistSource,
    queue: DispatchQueue = .global(qos: .userInitiated),
    completion: @escaping (Result<Playlist, Error>) -> Void
  ) {
    queue.async {
      do {
        let playlist = try self.parse(input)
        completion(.success(playlist))
      } catch {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
  }

  @available(iOS 15, tvOS 15, macOS 12, watchOS 8, *)
  /// Parse a playlist.
  /// - Parameter input: source.
  /// - Returns: playlist.
  public func parse(_ input: PlaylistSource) async throws -> Playlist {
    return try await withCheckedThrowingContinuation { continuation in
      self.parse(input) { result in
        continuation.resume(with: result)
      }
    }
  }
}
