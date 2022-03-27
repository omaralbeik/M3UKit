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

/// Object representing a TV channel.
public struct Channel: Equatable, Hashable, Codable {
    /// Create a new channel object.
    /// - Parameters:
    ///   - duration: duration.
    ///   - attributes: attributes.
    ///   - name: name.
    ///   - url: url.
    public init(
        duration: Int,
        attributes: ChannelAttributes,
        name: String,
        url: URL
    ) {
        self.duration = duration
        self.attributes = attributes
        self.name = name
        self.url = url
    }

    /// Duration, -1 for live channels.
    public var duration: Int

    /// Attributes.
    public var attributes: ChannelAttributes

    /// Channel name.
    public var name: String

    /// Channel URL.
    public var url: URL
}
