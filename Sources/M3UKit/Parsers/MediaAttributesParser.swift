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

final class MediaAttributesParser: Parser {
  typealias Attributes = Playlist.Media.Attributes

  func parse(_ input: String) -> Attributes {
    var attributes = Attributes()
    if let id = idRegex.firstMatch(in: input) {
      attributes.id = id
    }
    if let name = nameRegex.firstMatch(in: input) {
      let show = seasonEpisodeParser.parse(name)
      attributes.name = show.name
      attributes.seasonNumber = show.se?.s
      attributes.episodeNumber = show.se?.e
    }
    if let country = countryRegex.firstMatch(in: input) {
      attributes.country = country
    }
    if let language = languageRegex.firstMatch(in: input) {
      attributes.language = language
    }
    if let logo = logoRegex.firstMatch(in: input) {
      attributes.logo = logo
    }
    if let channelNumber = channelNumberRegex.firstMatch(in: input) {
      attributes.channelNumber = channelNumber
    }
    if let shift = shiftRegex.firstMatch(in: input) {
      attributes.shift = shift
    }
    if let groupTitle = groupTitleRegex.firstMatch(in: input) {
      attributes.groupTitle = groupTitle
    }
    return attributes
  }

  let seasonEpisodeParser = SeasonEpisodeParser()
  let idRegex: RegularExpression = #"tvg-id=\"(.?|.+?)\""#
  let nameRegex: RegularExpression = #"tvg-name=\"(.?|.+?)\""#
  let countryRegex: RegularExpression = #"tvg-country=\"(.?|.+?)\""#
  let languageRegex: RegularExpression = #"tvg-language=\"(.?|.+?)\""#
  let logoRegex: RegularExpression = #"tvg-logo=\"(.?|.+?)\""#
  let channelNumberRegex: RegularExpression = #"tvg-chno=\"(.?|.+?)\""#
  let shiftRegex: RegularExpression = #"tvg-shift=\"(.?|.+?)\""#
  let groupTitleRegex: RegularExpression = #"group-title=\"(.?|.+?)\""#
}
