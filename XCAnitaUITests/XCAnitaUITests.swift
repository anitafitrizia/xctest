//
//  XCAnitaUITests.swift
//  XCAnitaUITests
//
//  Created by anitafitrizia on 1/18/25.
//

import XCTest

extension XCUIElement {
    func waitAndAssertExists(timeout: TimeInterval = 5) {
        XCTAssertTrue(self.waitForExistence(timeout: timeout), "\(self.identifier) does not exist.")
    }

    func safeTap() {
        waitAndAssertExists()
        tap()
    }

    func clearAndTypeText(_ text: String) {
        waitAndAssertExists()
        tap()
        if let value = self.value as? String, !value.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count)
            typeText(deleteString)
        }
        typeText(text)
    }
}

final class XCAnitaUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Tear down resources after each test if needed
    }

    @MainActor
    func testFullFlowPage() throws {
        try testLoginPage()
        try testSingleUser()
        try testListUsers()
    }
    
    func testLoginPage() throws {
        let userNameData = "eve.holt@reqres.in"
        let passwordData = "cityslicka"
        
        let usernameTextField = app.textFields["usernameInput"]
        let passwordSecureField = app.secureTextFields["passwordInput"]
        let loginButton = app.buttons["loginButton"]
        let loginSuccess = app.staticTexts["welcomePage"]

        usernameTextField.clearAndTypeText(userNameData)
        passwordSecureField.clearAndTypeText(passwordData)
        loginButton.safeTap()
        loginSuccess.waitAndAssertExists()
    }
    
    func testLoginPageMock() throws {
        app.launchEnvironment = [
            "USE_MOCK_API": "true",
            "API_BASE_URL": "https://reqres.in/api/login",
            "LOGIN_USERNAME": "eve.holt@reqres.in",
            "LOGIN_PASSWORD": "cityslicka"
        ]
        app.launch()
        
        let loginButton = app.buttons["loginButton"]
        let loginSuccess = app.staticTexts["welcomePage"]
        
        loginButton.safeTap()
        loginSuccess.waitAndAssertExists()
        loginSuccess.waitAndAssertExists()
    }
    
    func testSingleUser() throws {
        let singleUserButton = app.buttons["getSingleUser"]
        let clearSingleUserButton = app.buttons["clearSingleUser"]
        let userFullNameLabel = app.staticTexts["userFullName"]
        let userEmailLabel = app.staticTexts["userEmail"]
        let expectedFullName = "Janet Weaver"
        let expectedEmail =  "janet.weaver@reqres.in"
        
        singleUserButton.safeTap()
        userFullNameLabel.waitAndAssertExists()
        userEmailLabel.waitAndAssertExists()
//        XCTAssertTrue(userFullNameLabel.waitForExistence(timeout: 5), "User Full Name label not found.")
//        XCTAssertTrue(userEmailLabel.exists, "User Email label not found.")

        XCTAssertNotNil(userFullNameLabel.label, "User Full Name should not be nil.")
        XCTAssertNotNil(userEmailLabel.label, "User Email should not be nil.")

        XCTAssertEqual(userFullNameLabel.label, expectedFullName, "User Full Name is incorrect.")
        XCTAssertEqual(userEmailLabel.label, expectedEmail, "User Email is incorrect.")
        
        clearSingleUserButton.safeTap()
    }
    
    func testSingleUserMock() throws {
        try testLoginPageMock()
        
        let singleUserButton = app.buttons["getSingleUser"]
        let clearSingleUserButton = app.buttons["clearSingleUser"]
        let userFullNameLabel = app.staticTexts["userFullName"]
        let userEmailLabel = app.staticTexts["userEmail"]
        let expectedFullName = "Janet Weaver"
        let expectedEmail =  "janet.weaver@reqres.in"
        
        singleUserButton.safeTap()
        userFullNameLabel.waitAndAssertExists()
        userEmailLabel.waitAndAssertExists()

        XCTAssertNotNil(userFullNameLabel.label, "User Full Name should not be nil.")
        XCTAssertNotNil(userEmailLabel.label, "User Email should not be nil.")

        XCTAssertEqual(userFullNameLabel.label, expectedFullName, "User Full Name is incorrect.")
        XCTAssertEqual(userEmailLabel.label, expectedEmail, "User Email is incorrect.")
        
        clearSingleUserButton.safeTap()
    }
    
    func testListUsers() throws {
        let listUsersButton = app.buttons["getListUsers"]
        let clearListUsersButton = app.buttons["clearListUsers"]

        listUsersButton.safeTap()
        clearListUsersButton.safeTap()
    }
}
