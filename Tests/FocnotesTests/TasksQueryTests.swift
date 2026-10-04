import XCTest
@testable import Focnotes

final class TasksQueryTests: XCTestCase {
    private func makeVault() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("FocnotesTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root.appendingPathComponent(".obsidian"), withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: root) }
        return root
    }

    private func waitForIndex(of root: URL, action: () -> Void) {
        let ready = expectation(description: "Task index ready")
        let observer = NotificationCenter.default.addObserver(forName: TasksQueryEngine.indexDidChange, object: nil, queue: .main) { notification in
            if (notification.object as? URL)?.standardizedFileURL.path == root.standardizedFileURL.path {
                ready.fulfill()
            }
        }
        defer { NotificationCenter.default.removeObserver(observer) }
        action()
        wait(for: [ready], timeout: 10)
    }

    func testIndexIsAsynchronousAndKeepsEditsMadeDuringScan() throws {
        let root = try makeVault()
        let file = root.appendingPathComponent("tareas: hoy.md")
        try "- [ ] antigua\r\n".write(to: file, atomically: true, encoding: .utf8)
        waitForIndex(of: root) {
            let initial = TasksQueryEngine.results(query: "not done", sourceFileURL: file)
            XCTAssertEqual(initial?.1.count, 0)
            XCTAssertTrue(TasksQueryEngine.isIndexing)
            TasksQueryEngine.updateFile(at: file, content: "- [ ] nueva 🦭\r\n- [x] terminada\r\n")
        }
        let results = try XCTUnwrap(TasksQueryEngine.results(query: "not done", sourceFileURL: file))
        XCTAssertEqual(results.1.map(\.description), ["nueva 🦭"])
        XCTAssertFalse(TasksQueryEngine.isIndexing)
    }

    func testIndexHandlesColonInFilenameAndCRLF() throws {
        let root = try makeVault()
        let file = root.appendingPathComponent("tareas: hoy.md")
        try "Título\r\n- [ ] pendiente 📅 2026-10-03\r\n- [x] lista\r\n".write(to: file, atomically: true, encoding: .utf8)
        waitForIndex(of: root) { _ = TasksQueryEngine.results(query: "not done", sourceFileURL: file) }
        let tasks = try XCTUnwrap(TasksQueryEngine.results(query: "not done", sourceFileURL: file)?.1)
        XCTAssertEqual(tasks.count, 1)
        let task = try XCTUnwrap(tasks.first)
        XCTAssertEqual(task.fileURL.resolvingSymlinksInPath(), file.resolvingSymlinksInPath())
        XCTAssertEqual(task.line, 2)
        XCTAssertNotNil(task.due)
        let updated = try TasksQueryEngine.toggle(task)
        XCTAssertTrue(updated.hasPrefix("Título\r\n- [x] pendiente 📅 2026-10-03 ✅ "))
        XCTAssertTrue(updated.hasSuffix("\r\n- [x] lista\r\n"))
        XCTAssertEqual(TasksQueryEngine.results(query: "not done", sourceFileURL: file)?.1.count, 0)
    }

    func testStaleTaskCannotToggleAnotherLine() throws {
        let root = try makeVault()
        let file = root.appendingPathComponent("tareas.md")
        try "- [ ] original\n".write(to: file, atomically: true, encoding: .utf8)
        waitForIndex(of: root) { _ = TasksQueryEngine.results(query: "not done", sourceFileURL: file) }
        let task = try XCTUnwrap(TasksQueryEngine.results(query: "not done", sourceFileURL: file)?.1.first)
        let changed = "- [ ] otra tarea\n- [ ] original\n"
        try changed.write(to: file, atomically: true, encoding: .utf8)
        XCTAssertThrowsError(try TasksQueryEngine.toggle(task))
        XCTAssertEqual(try String(contentsOf: file, encoding: .utf8), changed)
    }

    func testChangingVaultDiscardsPreviousScan() throws {
        let first = try makeVault()
        let second = try makeVault()
        let firstFile = first.appendingPathComponent("primera.md")
        let secondFile = second.appendingPathComponent("segunda.md")
        try "- [ ] primera\n".write(to: firstFile, atomically: true, encoding: .utf8)
        try "- [ ] segunda\n".write(to: secondFile, atomically: true, encoding: .utf8)
        waitForIndex(of: second) {
            _ = TasksQueryEngine.results(query: "not done", sourceFileURL: firstFile)
            _ = TasksQueryEngine.results(query: "not done", sourceFileURL: secondFile)
        }
        let tasks = try XCTUnwrap(TasksQueryEngine.results(query: "not done", sourceFileURL: secondFile)?.1)
        XCTAssertEqual(tasks.map(\.description), ["segunda"])
    }
}
