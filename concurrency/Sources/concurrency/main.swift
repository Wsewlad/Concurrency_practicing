import Foundation


class Counter: @unchecked Sendable {
    let lock = NSLock()
    var count = 0
    var maximum = 0
    
    func increment() {
        self.lock.lock()
        self.count += 1
        self.lock.unlock()
        self.maximum = max(self.count, self.maximum)
    }
    
    func decrement() {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.count -= 1
    }
}

actor CounterActor {
    var count = 0
    var maximum = 0
    func increment() {
        self.count += 1
        self.computeMaximum()
    }
    func decrement() {
        self.count -= 1
    }
    private func computeMaximum() {
        self.maximum = max(self.count, self.maximum)
    }
}

let counter = CounterActor()

for _ in 0..<workCount {
    Task {
        print("increment", Thread.current)
        await counter.increment()
    }
    Task {
        print("decrement", Thread.current)
        await counter.decrement()
    }
}

Thread.sleep(forTimeInterval: 1)
Task {
    await print("counter.count", counter.count)
    await print("counter.maximum", counter.maximum)
}

func doSomething() {
    let counter = Counter()
    Task {
        counter.increment()
    }
}

//func perform(client: DatabaseClient, work: @escaping @Sendable () -> Void) {
//    Task {
//        _ = try await client.fetchUsers()
//        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
//        work()
//    }
//    Task {
//        _ = try await client.fetchUsers()
//        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
//        work()
//    }
//    Task {
//        _ = try await client.fetchUsers()
//        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
//        work()
//    }
//}
//
//struct User {}
//struct DatabaseClient {
//    var fetchUsers: @Sendable () async throws -> [User]
//    var createUsers: @Sendable (User) async throws -> Void
//}
//extension DatabaseClient {
//    static let live = Self(
//        fetchUsers: { fatalError() },
//        createUsers: { _ in fatalError()}
//    )
//}
//
//Task {
//    var count = 0
//    for _ in 0..<workCount {
//        perform(client: .live) {
//            print("Hello")
//        }
//    }
//    try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
//    print(count)
//}

Thread.sleep(forTimeInterval: 5)
