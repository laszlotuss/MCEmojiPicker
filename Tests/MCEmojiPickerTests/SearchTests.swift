import XCTest
@_spi(JSON) @testable import MCEmojiPicker

final class SearchTests: XCTestCase {
    private func emojis(searching searchText: String) -> [String] {
        let viewModel = MCEmojiPickerViewModel()
        viewModel.updateSearchText(searchText)
        return viewModel.emojiCategories.flatMap({ $0.emojis }).map({ $0.string })
    }

    func testSearchByEmojiReturnsEveryVariant() {
        XCTAssertEqual(emojis(searching: "👍"), ["👍", "👍🏻", "👍🏼", "👍🏽", "👍🏾", "👍🏿"])
    }

    func testSearchByVariantReturnsEveryVariant() {
        XCTAssertEqual(emojis(searching: "👍🏽"), ["👍", "👍🏻", "👍🏼", "👍🏽", "👍🏾", "👍🏿"])
        XCTAssertEqual(emojis(searching: "👍🏿"), ["👍", "👍🏻", "👍🏼", "👍🏽", "👍🏾", "👍🏿"])
    }

    func testSearchByZWJVariantFindsItsEmoji() {
        XCTAssertEqual(emojis(searching: "🕵🏻‍♂️"), ["🕵‍♂️", "🕵🏻‍♂️", "🕵🏼‍♂️", "🕵🏽‍♂️", "🕵🏾‍♂️", "🕵🏿‍♂️"])
    }

    func testSearchByEmojiWithoutSkinToneSupport() {
        XCTAssertEqual(emojis(searching: "😀"), ["😀"])
        XCTAssertEqual(emojis(searching: "🇭🇺"), ["🇭🇺"])
        XCTAssertEqual(emojis(searching: "✌️"), ["✌️", "✌🏻", "✌🏼", "✌🏽", "✌🏾", "✌🏿"])
    }

    func testSearchBySeveralEmojis() {
        XCTAssertEqual(emojis(searching: "😀🎉"), ["😀", "🎉"])
    }

    func testSearchByTextIsUnchanged() {
        XCTAssertEqual(emojis(searching: "thumbsUp"), ["👍"])
        XCTAssertEqual(emojis(searching: "grinningFace"), ["😀", "😃", "😄", "😅"])
    }

    func testSearchWithoutMatches() {
        XCTAssertEqual(emojis(searching: "notAnEmojiOrASearchKey"), [])
    }

    func testSelectedVariantIsTheVariantItself() {
        let viewModel = MCEmojiPickerViewModel()
        viewModel.updateSearchText("👍")
        let darkVariant = viewModel.emoji(at: IndexPath(row: 5, section: 0))
        XCTAssertEqual(darkVariant.string, "👍🏿")
        // A variant offers no skin tone choice of its own, so it is selected on a plain tap.
        XCTAssertFalse(darkVariant.isSkinToneSupport)
    }
}
