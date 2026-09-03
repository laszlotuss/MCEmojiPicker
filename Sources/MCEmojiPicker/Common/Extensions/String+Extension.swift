// The MIT License (MIT)
//
// Copyright © 2022 Ivan Izyumkin
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

extension String {
    /// Scalars which only change how an emoji is rendered, not which emoji it is.
    ///
    /// Skin tone modifiers and presentation selectors turn an emoji into a variant of itself,
    /// so they are dropped before comparing one emoji with another.
    private static let emojiVariantScalarValues: Set<UInt32> = [
        // Text and emoji presentation selectors.
        0xFE0E, 0xFE0F,
        // Skin tone modifiers.
        0x1F3FB, 0x1F3FC, 0x1F3FD, 0x1F3FE, 0x1F3FF
    ]
    
    /// The emojis contained in the string.
    ///
    /// ```
    /// print("👍🏽 or 😀".containedEmojis) // ["👍🏽", "😀"]
    /// ```
    var containedEmojis: [String] {
        return compactMap({ $0.isEmoji ? String($0) : nil })
    }
    
    /// The string without skin tone modifiers and presentation selectors.
    ///
    /// It makes every variant of an emoji comparable with the emoji itself.
    /// ```
    /// print("👍🏽".withoutEmojiVariants) // "👍"
    /// print("🕵🏻‍♂️".withoutEmojiVariants) // "🕵‍♂"
    /// ```
    var withoutEmojiVariants: String {
        return String(
            String.UnicodeScalarView(
                unicodeScalars.filter({ !String.emojiVariantScalarValues.contains($0.value) })
            )
        )
    }
}

extension Character {
    /// A boolean indicating whether the character is displayed as an emoji rather than as text.
    ///
    /// Characters which are only emojis in combination with other scalars, like the digits
    /// of keycap sequences, are emojis only when they come with those scalars.
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmojiPresentation
            || (scalar.properties.isEmoji && unicodeScalars.count > 1)
    }
}
