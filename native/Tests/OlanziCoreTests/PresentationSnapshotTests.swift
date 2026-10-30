import Foundation
import XCTest
@testable import OlanziCore

final class PresentationSnapshotTests: XCTestCase {
    func testOnlyHeartbeatTelemetryIsIgnored() {
        let original = DeviceSnapshot()
        var changed = original
        changed.lastHeartbeat = Date(timeIntervalSince1970: 123)
        XCTAssertNotEqual(original, changed)
        XCTAssertTrue(changed.hasSamePresentation(as: original))
        changed.heartbeatEnabled = true
        XCTAssertFalse(changed.hasSamePresentation(as: original))
    }

    func testRuntimeAndUserVisibleChangesStillPublish() {
        let original = DeviceSnapshot()
        let changes: [(inout DeviceSnapshot) -> Void] = [
            { $0.connected = true }, { $0.online = true },
            { $0.heartbeatPausedForInactivity = true },
            { $0.controlHandoffFailed = true },
            { $0.busy = true }, { $0.error = "failure" },
            { $0.fn.active = true }, { $0.fn.pressed = true },
            { $0.batteryUpdatedAt = Date() },
            { $0.hostSaveResult = HostSaveResult(requestID: UUID()) }
        ]
        for change in changes {
            var updated = original
            change(&updated)
            XCTAssertFalse(updated.hasSamePresentation(as: original))
        }
    }
}
