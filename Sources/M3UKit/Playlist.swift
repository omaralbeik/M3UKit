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

/// Object representing a playlist containing media items.
public struct Playlist: Equatable, Hashable, Codable {

  /// Object representing a media.
  public struct Media: Equatable, Hashable, Codable {

    /// Object representing attributes for a media.
    public struct Attributes: Equatable, Hashable, Codable {
      /// Create a new attributes object.
      /// - Parameters:
      ///   - id: id.
      ///   - name: name.
      ///   - country: country.
      ///   - language: language.
      ///   - logo: logo.
      ///   - channelNumber: channel number.
      ///   - shift: shift.
      ///   - groupTitle: group title.
      ///   - seasonNumber: Season number (for TV shows).
      ///   - episodeNumber: Episode number (for TV shows).
      public init(
        id: String? = nil,
        name: String? = nil,
        country: String? = nil,
        language: String? = nil,
        logo: String? = nil,
        channelNumber: String? = nil,
        shift: String? = nil,
        groupTitle: String? = nil,
        seasonNumber: Int? = nil,
        episodeNumber: Int? = nil
      ) {
        self.id = id
        self.name = name
        self.country = country
        self.language = language
        self.logo = logo
        self.channelNumber = channelNumber
        self.shift = shift
        self.groupTitle = groupTitle
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
      }

      /// tvg-id.
      public var id: String?

      /// tvg-name.
      public var name: String?

      /// tvg-country.
      public var country: String?

      /// tvg-language.
      public var language: String?

      /// tvg-logo.
      public var logo: String?

      /// tvg-chno.
      public var channelNumber: String?

      /// tvg-shift.
      public var shift: String?

      /// group-title.
      public var groupTitle: String?

      /// Season number (for TV shows).
      public var seasonNumber: Int?

      /// Episode number (for TV shows).
      public var episodeNumber: Int?
    }

    /// Enum representing media kind.
    public enum Kind: String, Equatable, Hashable, Codable {
      case movie
      case series
      case live
      case unknown
    }

    internal typealias Metadata = (
      duration: Int,
      attributes: Attributes,
      name: String
    )

    internal init(
      metadata: Metadata,
      kind: Kind,
      url: URL
    ) {
      self.init(
        duration: metadata.duration,
        attributes: metadata.attributes,
        kind: kind,
        name: metadata.name,
        url: url
      )
    }

    /// Create a new media object.
    /// - Parameters:
    ///   - duration: duration.
    ///   - attributes: attributes.
    ///   - kind: kind.
    ///   - name: name.
    ///   - url: url.
    public init(
      duration: Int,
      attributes: Attributes,
      kind: Kind,
      name: String,
      url: URL
    ) {
      self.duration = duration
      self.attributes = attributes
      self.kind = kind
      self.name = name
      self.url = url
    }

    /// Duration, Usually -1 for live stream content.
    public var duration: Int

    /// Attributes.
    public var attributes: Attributes

    /// Kind.
    public var kind: Kind

    /// Media name.
    public var name: String

    /// Media URL.
    public var url: URL
  }

  /// Create a playlist.
  /// - Parameter medias: medias.
  public init(medias: [Media]) {
    self.medias = medias
  }

  /// Medias.
  public var medias: [Media]
}
