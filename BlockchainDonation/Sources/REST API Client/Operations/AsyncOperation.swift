import Foundation

class AsyncOperation: Operation {

    enum State: String {
        case isReady
        case isExecuting
        case isFinished
    }

    final var state: State = .isReady {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }

    override final var isReady: Bool {
        return super.isReady && state == .isReady
    }

    override final var isExecuting: Bool {
        return state == .isExecuting
    }

    override final var isFinished: Bool {
        return state == .isFinished
    }

    override final var isAsynchronous: Bool {
        return true
    }

    override func start() {
        guard !isCancelled else {
            state = .isFinished
            return
        }

        state = .isExecuting
        main()
    }

    override func main() {
        assertionFailure("Override in subclass")
    }

    override func cancel() {
        state = .isFinished
    }

}
