// The MIT License (MIT)
//
// Copyright © 2023 Ivan Izyumkin
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

/// Where each emoji's chosen skin tone and usage are kept. The usage makes up the Frequently Used category.
enum MCEmojiStorage {

    private(set) static var defaults: UserDefaults = .standard

    /// Moves the storage, for example to an App Group's defaults so several apps share their history.
    /// The first time this app moves off the standard defaults, its history there is merged into the new ones.
    static func use(_ newDefaults: UserDefaults) {
        defaults = newDefaults
        guard newDefaults !== UserDefaults.standard else { return }
        mergeStandardHistory(into: newDefaults)
    }

    /// Usage timestamps are combined; a skin tone already chosen in the new defaults stays.
    private static func mergeStandardHistory(into target: UserDefaults) {
        let mergedKey = "MCEmojiPicker.mergedStandardHistory." + (Bundle.main.bundleIdentifier ?? "app")
        guard !target.bool(forKey: mergedKey) else { return }
        let standard = UserDefaults.standard

        for emoji in MCUnicodeManager.defaultEmojis.flatMap({ $0.emojis }) {
            let skinToneKey = MCEmoji.StorageKeys.skinTone(emoji).key
            if let skinTone = standard.object(forKey: skinToneKey), target.object(forKey: skinToneKey) == nil {
                target.set(skinTone, forKey: skinToneKey)
            }

            let usageKey = MCEmoji.StorageKeys.usageTimestamps(emoji).key
            guard let usage = standard.array(forKey: usageKey) as? [TimeInterval], !usage.isEmpty else { continue }
            let targetUsage = (target.array(forKey: usageKey) as? [TimeInterval]) ?? []
            // Newest first, like the picker writes them.
            target.set(Array(Set(usage + targetUsage)).sorted(by: >), forKey: usageKey)
        }
        target.set(true, forKey: mergedKey)
    }
}
