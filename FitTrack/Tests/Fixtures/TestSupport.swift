import Combine
import CoreData
import XCTest
@testable import FitTrack

extension XCTestCase {
    func waitForResult<Value>(
        timeout: TimeInterval = 8,
        operation: (@escaping (Result<Value, Error>) -> Void) -> Void
    ) throws -> Result<Value, Error> {
        let finished = expectation(description: "Asynchronous operation completes")
        var received: Result<Value, Error>?
        operation { result in
            XCTAssertTrue(Thread.isMainThread, "Repository and lifecycle completions must use the main queue")
            received = result
            finished.fulfill()
        }
        wait(for: [finished], timeout: timeout)
        return try XCTUnwrap(received)
    }

    func startAndWait(_ model: BootstrapViewModel) {
        let finished = expectation(description: "Bootstrap leaves loading state")
        var didStart = false
        var didFinish = false
        let subscription = model.$state.sink { state in
            guard didStart, !didFinish else { return }
            switch state {
            case .ready, .failed:
                didFinish = true
                finished.fulfill()
            case .idle, .loading:
                break
            }
        }
        didStart = true
        model.start()
        wait(for: [finished], timeout: 5)
        subscription.cancel()
    }

    func openedMemoryStack() throws -> CoreDataStack {
        let stack = CoreDataStack(location: .inMemory)
        try waitForResult { stack.load(completion: $0) }.get()
        return stack
    }

    func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return url
    }

    func perform<Value>(
        in stack: CoreDataStack,
        operation: @escaping (NSManagedObjectContext) throws -> Value
    ) throws -> Value {
        let context = try stack.makeBackgroundContext()
        return try waitForResult { completion in
            context.perform {
                let result = Result { try operation(context) }
                DispatchQueue.main.async { completion(result) }
            }
        }.get()
    }
}

func insertedObject(_ entityName: String, in context: NSManagedObjectContext) -> NSManagedObject {
    let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    let date = Date(timeIntervalSince1970: 1_600_000_000)
    object.setValue(UUID(), forKey: "id")
    object.setValue(date, forKey: "createdAt")
    object.setValue(date, forKey: "updatedAt")
    return object
}
