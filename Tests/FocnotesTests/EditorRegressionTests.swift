import AppKit
import XCTest
@testable import Focnotes

final class EditorRegressionTests: XCTestCase {
    private func makeEditor(_ source: String) throws -> (NoteView, MarkdownTextView, NSWindow) {
        _ = NSApplication.shared
        let note = NoteView(frame: NSRect(x: 0, y: 0, width: 360, height: 180), fileURL: nil, initialText: source)
        let scrollView = try XCTUnwrap(note.subviews.compactMap { $0 as? NSScrollView }.first)
        let editor = try XCTUnwrap(scrollView.documentView as? MarkdownTextView)
        let window = NSWindow(contentRect: note.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = note
        note.layoutSubtreeIfNeeded()
        return (note, editor, window)
    }

    func testCheckboxToggleSupportsUndoAndRedo() throws {
        let (note, editor, window) = try makeEditor("- [ ] tarea\n")
        defer { window.close() }
        let undo = try XCTUnwrap(editor.undoManager)
        undo.removeAllActions()
        undo.beginUndoGrouping()
        editor.checkboxClicked?(NSRange(location: 2, length: 3))
        undo.endUndoGrouping()
        XCTAssertEqual(editor.string, "- [x] tarea\n")
        XCTAssertTrue(undo.canUndo)
        undo.undo()
        XCTAssertEqual(editor.string, "- [ ] tarea\n")
        undo.redo()
        XCTAssertEqual(editor.string, "- [x] tarea\n")
        withExtendedLifetime(note) {}
    }

    func testStaleCheckboxRangeCannotOverwriteText() throws {
        let (note, editor, window) = try makeEditor("Texto normal")
        defer { window.close() }
        editor.checkboxClicked?(NSRange(location: 2, length: 3))
        XCTAssertEqual(editor.string, "Texto normal")
        withExtendedLifetime(note) {}
    }

    func testEnterContinuesTasksAndScrollsBeforeTyping() throws {
        let source = (1...25).map { "- [ ] tarea \($0)" }.joined(separator: "\n")
        let (note, editor, window) = try makeEditor(source)
        defer { window.close() }
        editor.setSelectedRange(NSRange(location: (source as NSString).length, length: 0))
        editor.scrollRangeToVisible(editor.selectedRange())
        let before = editor.enclosingScrollView!.contentView.bounds.origin.y
        XCTAssertTrue(note.textView(editor, doCommandBy: #selector(NSResponder.insertNewline(_:))))
        XCTAssertTrue(editor.string.hasSuffix("tarea 25\n- [ ] "))
        let after = editor.enclosingScrollView!.contentView.bounds.origin.y
        XCTAssertGreaterThan(after, before)
        let layout = try XCTUnwrap(editor.layoutManager)
        let glyph = layout.glyphIndexForCharacter(at: (editor.string as NSString).length - 1)
        let line = layout.lineFragmentRect(forGlyphAt: glyph, effectiveRange: nil)
            .offsetBy(dx: editor.textContainerOrigin.x, dy: editor.textContainerOrigin.y)
        XCTAssertLessThanOrEqual(line.maxY, editor.visibleRect.maxY + 1)
    }

    func testInactiveCheckboxUsesOneSourceSpace() throws {
        let (note, editor, window) = try makeEditor("- [ ] tarea")
        defer { window.close() }
        let layout = try XCTUnwrap(editor.layoutManager)
        let container = try XCTUnwrap(editor.textContainer)
        layout.ensureLayout(for: container)
        let markerGlyphs = layout.glyphRange(forCharacterRange: NSRange(location: 2, length: 3), actualCharacterRange: nil)
        let marker = layout.boundingRect(forGlyphRange: markerGlyphs, in: container)
        let textGlyphs = layout.glyphRange(forCharacterRange: NSRange(location: 6, length: 1), actualCharacterRange: nil)
        let text = layout.boundingRect(forGlyphRange: textGlyphs, in: container)
        let space = (" " as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: AppPreferences.editorFontSize)]).width
        XCTAssertEqual(text.minX - (marker.minX + 3 + 14), space, accuracy: 1)
        withExtendedLifetime(note) {}
    }
}
