import Foundation
import Markdown

/// Source-dependent work shared by the renderer, drawing and mouse handling.
/// Selection and theme changes can reuse this snapshot without parsing again.
final class MarkdownAnalysis {
    struct FencedCodeBlock {
        let range: NSRange
        let codeRange: NSRange
        let language: String?
        let isClosed: Bool

        var isTasksQuery: Bool { ["task", "tasks"].contains(language?.lowercased() ?? "") }
    }

    private static let taskExpression = try! NSRegularExpression(
        pattern: "(?m)^[ \\t]*([-*+] (\\[[ xX]\\]))(?=[ \\t])"
    )
    private static let bulletExpression = try! NSRegularExpression(
        pattern: "(?m)^[ \\t]*([-*+])(?=[ \\t]+(?!\\[[ xX]\\]))"
    )
    private static let openingFenceExpression = try! NSRegularExpression(
        pattern: "^[ \\t]{0,3}(`{3,}|~{3,})[^\\r\\n]*(?:\\r?\\n|$)",
        options: .anchorsMatchLines
    )

    let source: String
    private let sourceNSString: NSString
    lazy var document = Document(parsing: source, options: [.disableSmartOpts])
    lazy var tasks = Self.taskExpression.matches(in: source, range: fullRange)
    lazy var bullets = Self.bulletExpression.matches(in: source, range: fullRange)
    lazy var fencedCodeBlocks = findFencedCodeBlocks()
    private lazy var lineStarts: [String.UTF8View.Index] = {
        var starts = [source.utf8.startIndex]
        for index in source.utf8.indices where source.utf8[index] == 0x0A {
            starts.append(source.utf8.index(after: index))
        }
        return starts
    }()

    init(source: String) {
        self.source = source
        sourceNSString = source as NSString
    }

    private var fullRange: NSRange { NSRange(location: 0, length: sourceNSString.length) }

    func codeToCopy(from block: FencedCodeBlock) -> String {
        var code = sourceNSString.substring(with: block.codeRange)
        // CRLF is a single Swift Character, just like LF.
        if code.hasSuffix("\r\n") || code.hasSuffix("\n") || code.hasSuffix("\r") {
            code.removeLast()
        }
        return code
    }

    func characterRange(for markup: Markup) -> NSRange? {
        guard let range = markup.range,
              let lower = stringIndex(for: range.lowerBound),
              let upper = stringIndex(for: range.upperBound),
              lower <= upper else { return nil }
        return NSRange(lower..<upper, in: source)
    }

    private func stringIndex(for location: SourceLocation) -> String.Index? {
        guard location.line > 0, location.line <= lineStarts.count, location.column > 0 else { return nil }
        let lineStart = lineStarts[location.line - 1]
        guard let utf8Index = source.utf8.index(
            lineStart,
            offsetBy: location.column - 1,
            limitedBy: source.utf8.endIndex
        ) else { return nil }
        return String.Index(utf8Index, within: source)
    }

    private func findFencedCodeBlocks() -> [FencedCodeBlock] {
        var blocks: [FencedCodeBlock] = []
        var searchLocation = 0
        while searchLocation < sourceNSString.length,
              let opening = Self.openingFenceExpression.firstMatch(
                in: source,
                range: NSRange(location: searchLocation, length: sourceNSString.length - searchLocation)
              ) {
            let fenceRange = opening.range(at: 1)
            let fenceCharacter = sourceNSString.substring(with: NSRange(location: fenceRange.location, length: 1))
            let escapedCharacter = NSRegularExpression.escapedPattern(for: fenceCharacter)
            let closingExpression = try? NSRegularExpression(
                pattern: "^[ \\t]{0,3}\(escapedCharacter){\(fenceRange.length),}[ \\t]*(?:\\r?\\n|$)",
                options: .anchorsMatchLines
            )
            let closing = closingExpression?.firstMatch(
                in: source,
                range: NSRange(location: NSMaxRange(opening.range), length: sourceNSString.length - NSMaxRange(opening.range))
            )
            let blockEnd = closing.map { NSMaxRange($0.range) } ?? sourceNSString.length
            let codeEnd = closing?.range.location ?? sourceNSString.length
            let infoStart = NSMaxRange(fenceRange)
            let info = sourceNSString.substring(with: NSRange(
                location: infoStart,
                length: NSMaxRange(opening.range) - infoStart
            )).trimmingCharacters(in: .whitespacesAndNewlines)

            blocks.append(FencedCodeBlock(
                range: NSRange(location: opening.range.location, length: blockEnd - opening.range.location),
                codeRange: NSRange(location: NSMaxRange(opening.range), length: codeEnd - NSMaxRange(opening.range)),
                language: info.split(whereSeparator: \Character.isWhitespace).first.map(String.init),
                isClosed: closing != nil
            ))
            searchLocation = blockEnd
        }
        return blocks
    }
}

final class MarkdownAnalysisCache {
    private var cached: MarkdownAnalysis?

    func analysis(for source: String) -> MarkdownAnalysis {
        // Compare code units: canonically equivalent Unicode can have different source offsets.
        if let cached, cached.source.utf8.elementsEqual(source.utf8) { return cached }
        let analysis = MarkdownAnalysis(source: source)
        cached = analysis
        return analysis
    }
}
