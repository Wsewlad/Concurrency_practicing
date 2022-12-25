import Foundation

@MainActor
class ViewModel: ObservableObject {
    @Published var count = 0
    
    func perform() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                while true {
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC / 4)
                    print(Thread.current, "Timer ticked")
                }
            }
            group.addTask { @MainActor in
                await asyncNthPrime(2_000_000)
            }
            for n in 0..<workCount {
                group.addTask { @MainActor in
                    _ = try await URLSession.shared.data(from: .init(string: "https://ipv4.download.thinkbroadband.com/1MB.zip")!)
                    print(Thread.current, "Download finished", n)
                }
            }
        }
    }
    
//    func perform() async throws {
//        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
//        MyLocals.$id.withValue(42) {
//            defer { print("withValue scope ended") }
//            if !Thread.current.isMainThread {
//                print("Mutating @Published property on non-main thread.")
//            }
//            self.count = MyLocals.id
//            print("count", self.count)
////            DispatchQueue.main.async {
////                if !Thread.current.isMainThread {
////                    print("Mutating @Published property on non-main thread.")
////                }
////                print("On the main thread")
////                self.count = MyLocals.id
////            }
//        }
//    }
}

@main
struct Main {
    static func main() async throws {
        let viewModel = ViewModel()
        try await viewModel.perform()
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
    }
}

//
///*
//
//var x = 0
//outer: var y = 0
//inner: if x.isMultiple(of: 2) && y.isMultiple(of: 2) {
//    print(x)
//}
//y += 1
//if y <= 100 {
//    continue inner
//}
//x += 1
//id x <= 100 {
//    continue outer
//}
//
//*/
//
////func loops() {
////    defer { print("1 Outer loop has finished") }
////    defer { print("2 Outer loop has finished") }
////    defer { print("3 Outer loop has finished") }
////
////    for x in 0...100 {
////        defer { print("Inner loop has finished") }
////
////        for y in 0...100 {
////            if x.isMultiple(of: 3) && y.isMultiple(of: 5) {
////                print(x, y)
////            }
////        }
////    }
////}
////
////func add(_ lhs: Int, _ rhs: Int) -> Int {
////    lhs + rhs
////}
//
////add(3, 4)
//
////loops()
//
//enum RequestData {
//    @TaskLocal static var requestId: UUID!
//    @TaskLocal static var startDate: Date!
//}
//
//struct User: Encodable { var id: Int }
//func fetchUser() async throws -> User {
//    let requestId = RequestData.requestId!
//    defer { print(requestId, "databaseQuery", "isCancelled", Task.isCancelled) }
//    print(requestId, "Making database query")
//    try await Task.sleep(nanoseconds: 500_000_000)
//    print(requestId, "Finised database query")
//    return .init(id: 42)
//}
//
//struct StripeSubscription: Encodable { var id: Int }
//func fetchSubscription() async throws -> StripeSubscription{
//    let requestId = RequestData.requestId!
//    defer { print(requestId, "networkRequest", "isCancelled", Task.isCancelled) }
//    print(requestId, "Making network request")
//    try await Task.sleep(nanoseconds: 500_000_000)
//    print(requestId, "Finised network request")
//    return .init(id: 1729)
//}
//
//struct Response: Encodable {
//    let user: User
//    let subscription: StripeSubscription
//}
//func response(for quest: URLRequest) async throws -> (Data, HTTPURLResponse) {
//    let requestId = RequestData.requestId!
//    let start = RequestData.startDate!
//
//    defer { print(requestId, "Request finished in", Date().timeIntervalSince(start)) }
//
//    Task {
//        print(RequestData.requestId!, "Track analytics")
//    }
//    async let user = fetchUser()
//    async let subscription = fetchSubscription()
//
//    let jsonData = try await JSONEncoder().encode(Response(user: user, subscription: subscription))
//
//    return (jsonData, .init())
//}
//
////RequestData.$requestId.withValue(UUID()) {
////    RequestData.$startDate.withValue(Date()) {
////        let task = Task {
////            let _ = try await response(for: .init(url: .init(string: "https://pointfree.co")!))
////        }
////        Thread.sleep(forTimeInterval: 0.1)
////        task.cancel()
////    }
////}
//
//Task {
//    let sum = await withTaskGroup(of: Int.self, returning: Int.self) { group in
//        for n in 1...1000 {
//            group.addTask {
//                try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
//                return n
//            }
//        }
//
//        var sum = 0
//        for await n in group {
//            sum += n
//        }
//
//        return sum
//    }
//    print("sum", sum)
//}
//
//Thread.sleep(forTimeInterval: 5)
