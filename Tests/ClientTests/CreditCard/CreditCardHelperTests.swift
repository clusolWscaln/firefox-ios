// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import Client
import Foundation
import XCTest
import WebKit
import Shared
import Common
import Storage

class MockWKScriptMessage: WKScriptMessage {
    var mockBody: Any
    var mockName: String

    init(name: String, body: Any) {
        mockName = name
        mockBody = body
    }

    override var body: Any {
        return mockBody
    }

    override var name: String {
        return mockName
    }
}

class CreditCardHelperTests: XCTestCase {
    var creditCardHelper: CreditCardHelper!
    var tab: Tab!
    var profile: MockProfile!
    var validMockWKMessage: MockWKScriptMessage!
    let validMockPayloadJson = """
        {
          "type" : "fill-credit-card-form",
          "payload" : {
            "cc-number" : "1234 4567 4567 6788",
            "cc-name" : "Josh Moustache",
            "cc-exp-month" : "03",
            "cc-exp" : "02",
            "cc-exp-year" : "2999"
          }
        }
    """

    override func setUp() {
        super.setUp()
        profile = MockProfile(databasePrefix: "CreditCardHelper_tests")
        profile.reopen()
        tab = Tab(profile: profile, configuration: WKWebViewConfiguration())
        creditCardHelper = CreditCardHelper(tab: tab)
        guard let jsonData = validMockPayloadJson.data(using: .utf8),
              let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            fatalError("Unable to convert JSON to dictionary")
        }
        validMockWKMessage = MockWKScriptMessage(name: "mock_message", body: dictionary)
    }

    override func tearDown() {
        super.tearDown()
        profile.shutdown()
        profile = nil
        tab = nil
        creditCardHelper = nil
        validMockWKMessage = nil
    }

    // MARK: Parsing

    func test_getValidPayloadData() {
        XCTAssertNotNil(creditCardHelper.getValidPayloadData(from: validMockWKMessage))
    }

    func test_parseFieldType_valid() {
        let messageBodyDict = creditCardHelper.getValidPayloadData(from: validMockWKMessage)
        let messageFields = creditCardHelper.parseFieldType(messageBody: messageBodyDict!)
        XCTAssertNotNil(messageFields)
        XCTAssertEqual(messageFields!.creditCardPayload.ccExpMonth, "03")
        XCTAssertEqual(messageFields!.creditCardPayload.ccExpYear, "2999")
        XCTAssertEqual(messageFields!.creditCardPayload.ccName, "Josh Moustache")
        XCTAssertEqual(messageFields!.creditCardPayload.ccNumber, "1234 4567 4567 6788")
    }
}
