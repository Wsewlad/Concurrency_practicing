//public struct concurrency {
//    public private(set) var text = "Hello, World!"
//
//    public init() {
//    }
//}

import Foundation

Thread.detachNewThread {
    Thread.sleep(forTimeInterval: 1)
    print(Thread.current)
}
