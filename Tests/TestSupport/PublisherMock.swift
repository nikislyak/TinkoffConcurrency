import Foundation
import Combine

class PublisherMock<Output, Failure: Error>: Publisher, Cancellable {

    private let lock = NSLock()
    private(set) var subscribers: [AnySubscriber<Output, Failure>] = []
    private(set) var subscriptions: [SubscriptionMock] = []

    var willSubscribe: ((AnySubscriber<Output, Failure>, SubscriptionMock) -> Void)?

    var didSubscribe: ((AnySubscriber<Output, Failure>, SubscriptionMock) -> Void)?

    var onDeinit: (() -> Void)?

    var invokedCancel: Bool = false
    var onCancel: (() -> Void)?

    required init() {
    }

    deinit {
        onDeinit?()
    }

    func receive<Downstream: Subscriber>(subscriber: Downstream)
        where Failure == Downstream.Failure, Output == Downstream.Input
    {
        let anySubscriber = AnySubscriber(subscriber)
        lock.access {
            self.subscribers.append(anySubscriber)
        }

        let subscription = SubscriptionMock()

        willSubscribe?(anySubscriber, subscription)

        lock.access {
            self.subscriptions.append(subscription)
        }
        subscriber.receive(subscription: subscription)

        didSubscribe?(anySubscriber, subscription)
    }

    func cancel() {
        invokedCancel = true
        onCancel?()
    }
}
