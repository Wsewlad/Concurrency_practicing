//
//  Task.swift
//  
//
//  Created by  Vladyslav Fil on 01.11.2022.
//

import Foundation

func taskBasics() throws {
    let task = Task<Int, Error> {
        struct SomeError: Error {}
        throw SomeError()
        return 42
    }
    
    func doSomethingAsync() async {}
    
    Task {
        await doSomethingAsync()
    }
    
    func doSomethingElseAsync() async {
        await doSomethingAsync()
    }
    
    func doSomethingThatCanFail() throws {}
    
    try doSomethingThatCanFail()
    
    func doSomething() /* throws */ {
        do {
            try doSomethingThatCanFail()
        } catch let error {
            // TODO: Handle error
        }
    }
    
    // (A) throws -> B
    // (A) -> Result<B, Error>
    
    // (inout A) -> B
    // (A) -> (B, A)
    
    // (A) async -> B
    // (A) -> Task<B, Never>
    // (A) -> ((B) -> Void) -> Void
    // (A, (B) -> Void) -> Void
    
    //URLSession.shared.dataTask(with: <#T##URLRequest#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)
    
    for n in 0..<workCount {
        Task {
            let current = Thread.current
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            if current != Thread.current {
                print(n, "Thread changed from", current, "to", Thread.current)
            }
        }
    }
}

func taskPriority() {
    Task(priority: .low) {
        print("low")
    }
    Task(priority: .high) {
        print("high")
    }
}

func taskCancellation() {
    //let task = Task {
    //    try Task.checkCancellation()
    ////    guard !Task.isCancelled
    ////    else {
    ////        print("Cancelled")
    ////        return
    ////    }
    //    print(Thread.current)
    //}
    
    func doSomething() async throws {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
    }
    
    let task = Task {
        let start = Date()
        defer { print("Task finished in", Date().timeIntervalSince(start)) }
        
        //    try await doSomething()
        let (data, _) = try await URLSession.shared.data(from: .init(string: "https://ipv4.download.thinkbroadband.com/1MB.zip")!)
        print(Thread.current, "Network request finished", data.count)
    }
    
    Thread.sleep(forTimeInterval: 0.5)
    task.cancel()
}

func taskStorageAndCoordination() {
    enum RequestData {
        @TaskLocal static var requestId: UUID!
        @TaskLocal static var startDate: Date!
    }
    
    func databaseQuery() async throws {
        let requestId = RequestData.requestId!
        print(requestId, "Making database query")
        try await Task.sleep(nanoseconds: 500_000_000)
        print(requestId, "Finised database query")
    }
    
    func networkRequest() async throws {
        let requestId = RequestData.requestId!
        print(requestId, "Making network request")
        try await Task.sleep(nanoseconds: 500_000_000)
        print(requestId, "Finised network request")
    }
    
    func response(for quest: URLRequest) async throws -> HTTPURLResponse {
        let requestId = RequestData.requestId!
        let start = RequestData.startDate!
        
        defer { print(requestId, "Request finished in", Date.timeIntervalSince(start)) }
        
        Task {
            print(RequestData.requestId!, "Track analytics")
        }
        try await databaseQuery()
        try await networkRequest()
        
        
        return .init()
    }
    
    //RequestData.$requestId.withValue(UUID()) {
    //    RequestData.$startDate.withValue(Date()) {
    //        Task {
    //            let _ = try await response(for: .init(url: .init(string: "https://pointfree.co")!))
    //        }
    //    }
    //}
    
//    enum MyLocals {
//        @TaskLocal static var id: Int!
//        
//        //    @TaskLocal var api: APIClient
//        //    @TaskLocal var database: DatabaseClient
//        //    @TaskLocal var stripe: StripeClient
//    }
    
    //func doSomething() async {
    //    print("doSomething:", MyLocals.id!)
    //}
    //
    //print("before:", MyLocals.id)
    //MyLocals.$id.withValue(42) {
    //    print("withValue:", MyLocals.id!)
    //    Task {
    //        MyLocals.$id.withValue(1729) {
    //            Task {
    //                try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
    //                print("Task 2:", MyLocals.id!)
    //            }
    //        }
    //        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
    //        Task {
    //            print("Task:", MyLocals.id!)
    //            await doSomething()
    //        }
    //    }
    //}
    //print("after:", MyLocals.id)
    
    
    
    ////for _ in 0..<workCount {
    ////    Thread.detachNewThread {
    ////        while true {}
    ////    }
    ////}
    //Thread.detachNewThread {
    //    print("Starting prime thread")
    //    nthPrime(50_000)
    //}
    
    for _ in 0..<workCount {
        Task {
            while true {
                await Task.yield()
            }
        }
    }
    Task {
        print("Starting prime thread")
        nthPrime(20_000)
    }
}
