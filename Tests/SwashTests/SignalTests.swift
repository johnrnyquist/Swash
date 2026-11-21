//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swash

final class SignalTest: XCTestCase {
    var signal: Signaler0!
    var selfRemoverListener: Listener!
    var fail: Listener!

    override func setUpWithError() throws {
        signal = Signaler0()
    }

    override func tearDownWithError() throws {
        signal = nil
    }

    func test_newSignalHasNilHead() {
        XCTAssertNil(signal.head)
    }

    func test_newSignalHasListenersCountZero() {
        XCTAssertEqual(signal.numListeners, 0)
    }

    func test_addListenerThenDispatchShouldCallIt() {
        var result = 0
        signal.add(Listener { result = 1 })
        dispatchSignal()
        XCTAssertEqual(result, 1)
    }

    func dispatchSignal() {
        signal.dispatch()
    }

    func test_addListenerThenListenersCountIsOne() {
        signal.add(Listener {})
        XCTAssertEqual(signal.numListeners, 1)
    }

    func test_addListenerThenRemoveThenDispatchShouldNotCallListener() {
        let fail = Listener(failIfCalled)
        signal.add(fail)
        signal.remove(fail)
        dispatchSignal()
    }

    func failIfCalled() {
        XCTFail("This function should not have been called.")
    }

    func test_addListenerThenRemoveThenListenersCountIsZero() {
        let fail = Listener(failIfCalled)
        signal.add(fail)
        signal.remove(fail)
        XCTAssertEqual(signal.numListeners, 0)
    }

    func test_removeFunctionNotInListenersShouldNotThrowError() {
        signal.remove(Listener {})
        dispatchSignal()
    }

    func test_addListenerThenRemoveFunctionNotInListenersShouldStillCallListener() {
        let empty = Listener {}
        signal.add(empty)
        signal.remove(empty)
        dispatchSignal()
    }

    func test_add2ListenersThenDispatchShouldCallBoth() {
        var result = 0
        signal.add(Listener { result += 1 })
        signal.add(Listener { result += 2 })
        dispatchSignal()
        XCTAssertEqual(result, 3)
    }

    func test_add2ListenersThenListenersCountIsTwo() {
        signal.add(Listener {})
        signal.add(Listener {})
        XCTAssertEqual(signal.numListeners, 2)
    }

    func test_add2ListenersRemove1stThenDispatchShouldCall2ndNot1stListener() {
        let fail = Listener(failIfCalled)
        signal.add(fail)
        signal.add(Listener {})
        signal.remove(fail)
        dispatchSignal()
    }

    func test_add2ListenersRemove2ndThenDispatchShouldCall1stNot2ndListener() {
        let fail = Listener(failIfCalled)
        signal.add(Listener {})
        signal.add(fail)
        signal.remove(fail)
        dispatchSignal()
    }

    func test_add2ListenersThenRemove1ThenListenersCountIsOne() {
        let fail = Listener(failIfCalled)
        signal.add(Listener {})
        signal.add(fail)
        signal.remove(fail)
        XCTAssertEqual(signal.numListeners, 1)
    }

    func test_addSameListenerTwiceShouldOnlyAddItOnce() {
        var count = 0
        let function = Listener { count += 1 }
        signal.add(function)
        signal.add(function)
        dispatchSignal()
        XCTAssertEqual(count, 1)
    }

    func test_addTheSameListenerTwiceShouldNotThrowError() {
        let listener = Listener {}
        signal.add(listener)
        signal.add(listener)
    }

    func test_addSameListenerTwiceThenListenersCountIsOne() {
        let fail = Listener(failIfCalled)
        signal.add(fail)
        signal.add(fail)
        XCTAssertEqual(signal.numListeners, 1)
    }

    func test_dispatch2Listeners1stListenerRemovesItselfThen2ndListenerIsStillCalled() {
        var result = 0
        selfRemoverListener = Listener(selfRemover)
        signal.add(selfRemoverListener)
        signal.add(Listener { result = 1 })
        dispatchSignal()
        XCTAssertEqual(result, 1)
    }

    func selfRemover() {
        signal.remove(selfRemoverListener)
    }

    func test_dispatch2Listeners2ndListenerRemovesItselfThen1stListenerIsStillCalled() {
        var result = 0
        selfRemoverListener = Listener(selfRemover)
        signal.add(Listener { result = 1 })
        signal.add(selfRemoverListener)
        dispatchSignal()
        XCTAssertEqual(result, 1)
    }

    func test_addingAListenerDuringDispatchShouldNotCallIt() {
        signal.add(Listener(addListenerDuringDispatch))
        dispatchSignal()
    }

    func addListenerDuringDispatch() {
        let fail = Listener(failIfCalled)
        signal.add(fail)
    }

    func test_addingAListenerDuringDispatchIncrementsListenersCount() {
        signal.add(Listener(addListenerDuringDispatchToTestCount))
        dispatchSignal()
        XCTAssertEqual(signal.numListeners, 2)
    }

    func addListenerDuringDispatchToTestCount() {
        XCTAssertEqual(signal.numListeners, 1)
        signal.add(Listener {})
        XCTAssertEqual(signal.numListeners, 2)
    }

    func test_dispatch2Listeners2ndListenerRemoves1stThen1stListenerIsNotCalled() {
        fail = Listener(failIfCalled)
        signal.add(Listener(removeFailListener))
        signal.add(fail)
        dispatchSignal()
    }

    func removeFailListener() {
        signal.remove(fail)
    }

    func test_add2ListenersThenRemoveAllShouldLeaveNoListeners() {
        signal.add(Listener {})
        signal.add(Listener {})
        signal.removeAll()
        XCTAssertNil(signal.head)
    }

    func test_addListenerThenRemoveAllThenAddAgainShouldAddListener() {
        let handler = Listener {}
        signal.add(handler)
        signal.removeAll()
        signal.add(handler)
        XCTAssertEqual(signal.numListeners, 1)
    }

    func test_add2ListenersThenRemoveAllThenListenerCountIsZero() {
        signal.add(Listener {})
        signal.add(Listener {})
        signal.removeAll()
        XCTAssertEqual(signal.numListeners, 0)
    }

    func test_removeAllDuringDispatchShouldStopAll() {
        var result = 0
        let fail = Listener(failIfCalled)
        signal.add(Listener(removeAllListeners))
        signal.add(fail)
        signal.add(Listener { result = 1 })
        dispatchSignal()
        XCTAssertEqual(result, 0)
    }

    func removeAllListeners() {
        signal.removeAll()
    }

    func test_removeAllDuringDispatchAllowsPendingListenerToBeAddedAgain() {
        var calls = 0
        let pending = Listener { calls += 1 }
        let discarded = Listener(failIfCalled)
        signal.add(Listener {
            self.signal.add(pending)
            self.signal.add(discarded)
            self.signal.removeAll()
            self.signal.remove(discarded)
            XCTAssertEqual(self.signal.numListeners, 0)
            self.signal.add(pending)
        })

        signal.dispatch()
        XCTAssertEqual(calls, 0)
        XCTAssertEqual(signal.numListeners, 1)
        signal.dispatch()
        XCTAssertEqual(calls, 1)
    }

    func test_removeAllDuringDispatchDefersReplacementListeners() {
        var calls: [String] = []
        signal.add(Listener {
            self.signal.removeAll()
            self.signal.addOnce(Listener { calls.append("once") })
            self.signal.add(Listener { calls.append("regular") })
        })

        signal.dispatch()
        XCTAssertEqual(calls, [])
        XCTAssertEqual(signal.numListeners, 2)
        signal.dispatch()
        signal.dispatch()
        XCTAssertEqual(calls, ["once", "regular", "regular"])
        XCTAssertEqual(signal.numListeners, 1)
    }

    func test_removeAllClearsRegistrationsMadeByListenerDeinitializers() {
        final class Observer {
            let onRelease: () -> Void
            init(onRelease: @escaping () -> Void) { self.onRelease = onRelease }
            deinit { onRelease() }
        }

        for duringDispatch in [false, true] {
            let signal = Signaler0()
            var calls = 0
            let listener = Listener { calls += 1 }
            if duringDispatch { signal.add(Listener { signal.removeAll() }) }
            do {
                let observer = Observer { signal.add(listener) }
                signal.add(Listener { withExtendedLifetime(observer) {} })
            }

            if duringDispatch { signal.dispatch() } else { signal.removeAll() }

            XCTAssertEqual(signal.numListeners, 0)
            signal.add(listener)
            signal.dispatch()
            XCTAssertEqual(calls, 1)
            signal.remove(listener)
            XCTAssertEqual(signal.numListeners, 0)
        }
    }

    func test_removeAllInNestedDispatchDefersAdditionsUntilOutermostDispatchEnds() {
        var nested = false
        var calls: [String] = []
        signal.add(Listener {
            if nested {
                self.signal.removeAll()
                self.signal.add(Listener { calls.append("inner addition") })
            } else {
                nested = true
                self.signal.dispatch()
                self.signal.add(Listener { calls.append("outer addition") })
                self.signal.dispatch()
            }
        })

        signal.dispatch()
        XCTAssertEqual(calls, [])
        XCTAssertEqual(signal.numListeners, 2)
        signal.dispatch()
        XCTAssertEqual(calls, ["inner addition", "outer addition"])
    }

    func test_nestedDispatchWithoutClearingPreservesListenerOrder() {
        var didNest = false
        var calls: [String] = []
        signal.add(Listener {
            calls.append("driver")
            guard !didNest else { return }
            didNest = true
            self.signal.add(Listener { calls.append("before nested dispatch") })
            self.signal.dispatch()
            self.signal.add(Listener { calls.append("after nested dispatch") })
        })
        signal.add(Listener { calls.append("tail") })

        signal.dispatch()

        XCTAssertEqual(calls, ["driver", "driver", "tail", "tail",
                               "before nested dispatch", "after nested dispatch"])
    }

    func test_addOnceListenerThenDispatchShouldCallIt() {
        var result = 0
        signal.addOnce(Listener { result += 1 })
        dispatchSignal()
        XCTAssertEqual(result, 1)
    }

    func test_addOnceListenerShouldBeRemovedAfterDispatch() {
        signal.addOnce(Listener {})
        dispatchSignal()
        XCTAssertNil(signal.head)
    }

    func test_regularListenerPersistsWhenAddedAfterOneShotListenerFires() {
        signal.addOnce(Listener {})
        signal.dispatch()

        var calls = 0
        signal.add(Listener { calls += 1 })
        signal.dispatch()
        signal.dispatch()

        XCTAssertEqual(calls, 2)
        XCTAssertEqual(signal.numListeners, 1)
    }
}
