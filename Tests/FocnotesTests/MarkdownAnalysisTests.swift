import XCTest
import Markdown
@testable import Focnotes

final class MarkdownAnalysisTests: XCTestCase {
    func testUnchangedSourceReusesAnalysisAndEditsInvalidateIt() {
        let cache = MarkdownAnalysisCache()
        let original = cache.analysis(for: "- [ ] tarea\n")
        XCTAssertTrue(original === cache.analysis(for: "- [ ] tarea\n"))
        let edited = cache.analysis(for: "- [x] tarea\n- [ ] otra\n")
        XCTAssertFalse(original === edited)
        XCTAssertEqual(edited.tasks.count, 2)
        XCTAssertEqual((edited.source as NSString).substring(with: edited.tasks[0].range(at: 2)), "[x]")
    }

    func testCanonicallyEquivalentUnicodeInvalidatesSourceOffsets() {
        let cache = MarkdownAnalysisCache()
        let composed = cache.analysis(for: "é\n- [ ] tarea")
        let decomposed = cache.analysis(for: "e\u{301}\n- [ ] tarea")
        XCTAssertEqual(composed.source, decomposed.source)
        XCTAssertFalse(composed === decomposed)
        XCTAssertEqual(decomposed.tasks[0].range.location, composed.tasks[0].range.location + 1)
    }

    func testUnicodeMarkupRangesPreserveExactSource() throws {
        let source = "# Español 👩🏽‍💻\n\n**café 🦭**\n"
        let analysis = MarkdownAnalysis(source: source)
        let heading = try XCTUnwrap(analysis.document.children.first(where: { $0 is Heading }) as? Heading)
        let range = try XCTUnwrap(analysis.characterRange(for: heading))
        XCTAssertEqual((source as NSString).substring(with: range), "# Español 👩🏽‍💻")
    }

    func testFencedBlocksRespectFenceLengthAndCRLF() {
        let source = "````swift\r\na\r\n```\r\nb\r\n````\r\n\n~~~tasks\nnot done\n~~~\n\n```\nunclosed"
        let blocks = MarkdownAnalysis(source: source).fencedCodeBlocks
        XCTAssertEqual(blocks.count, 3)
        XCTAssertEqual((source as NSString).substring(with: blocks[0].codeRange), "a\r\n```\r\nb\r\n")
        XCTAssertTrue(blocks[0].isClosed)
        XCTAssertTrue(blocks[1].isTasksQuery)
        XCTAssertTrue(blocks[1].isClosed)
        XCTAssertFalse(blocks[2].isClosed)
    }

    func testCodeCopyRemovesOnlyOneTrailingLineEnding() throws {
        for newline in ["\n", "\r\n"] {
            for code in ["a", "🦭", "", "primera\(newline)segunda\(newline)"] {
                let source = "```\(newline)\(code)\(newline)```\(newline)"
                let analysis = MarkdownAnalysis(source: source)
                let block = try XCTUnwrap(analysis.fencedCodeBlocks.first)
                XCTAssertEqual(analysis.codeToCopy(from: block), code)
            }
        }
    }
}
