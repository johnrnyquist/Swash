//
// Created by John Nyquist on 11/14/22.
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

    func test_newSignalHasNullHead() {
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
}
