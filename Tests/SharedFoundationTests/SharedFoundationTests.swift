import XCTest
@testable import SharedFoundation

final class SharedFoundationTests: XCTestCase {

    // MARK: - User Tests

    func testCreateAnonymousUser() {
        let user = User.createAnonymous()

        XCTAssertNotNil(user.id)
        XCTAssertNil(user.appleId)
        XCTAssertTrue(user.isAnonymous)
        XCTAssertFalse(user.isAuthenticated)
        XCTAssertEqual(user.displayName, "ゲスト")
    }

    func testUserPremiumStatus() {
        // プレミアムなし
        let freeUser = User(isPremium: false)
        XCTAssertFalse(freeUser.isPremiumActive)

        // プレミアムあり（期限なし）
        let premiumUser = User(isPremium: true)
        XCTAssertTrue(premiumUser.isPremiumActive)

        // プレミアムあり（期限切れ）
        let expiredUser = User(
            isPremium: true,
            premiumExpiresAt: Date().addingTimeInterval(-86400)
        )
        XCTAssertFalse(expiredUser.isPremiumActive)

        // プレミアムあり（有効期限内）
        let validUser = User(
            isPremium: true,
            premiumExpiresAt: Date().addingTimeInterval(86400)
        )
        XCTAssertTrue(validUser.isPremiumActive)
    }

    // MARK: - DateUtils Tests

    func testDateFormat() {
        let date = DateUtils.parse("2024-01-15", format: .apiDate)!

        XCTAssertEqual(DateUtils.format(date, format: .fullDate), "2024年1月15日")
        XCTAssertEqual(DateUtils.format(date, format: .monthDay), "1月15日")
        XCTAssertEqual(DateUtils.format(date, format: .shortDate), "1/15")
    }

    func testRelativeFormat() {
        let today = Date()
        XCTAssertEqual(DateUtils.relativeFormat(today), "今日")

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertEqual(DateUtils.relativeFormat(yesterday), "昨日")
    }

    func testTimeAgo() {
        let now = Date()
        XCTAssertEqual(DateUtils.timeAgo(now), "たった今")

        let fiveMinutesAgo = now.addingTimeInterval(-300)
        XCTAssertEqual(DateUtils.timeAgo(fiveMinutesAgo), "5分前")

        let twoHoursAgo = now.addingTimeInterval(-7200)
        XCTAssertEqual(DateUtils.timeAgo(twoHoursAgo), "2時間前")
    }

    // MARK: - ValidationUtils Tests

    func testNotEmpty() {
        let valid = ValidationUtils.notEmpty("テスト", fieldName: "名前")
        XCTAssertTrue(valid.isValid)

        let invalid = ValidationUtils.notEmpty("", fieldName: "名前")
        XCTAssertFalse(invalid.isValid)
        XCTAssertEqual(invalid.errorMessage, "名前を入力してください")

        let whitespace = ValidationUtils.notEmpty("   ", fieldName: "名前")
        XCTAssertFalse(whitespace.isValid)
    }

    func testMaxLength() {
        let valid = ValidationUtils.maxLength("短い", maxLength: 10, fieldName: "メモ")
        XCTAssertTrue(valid.isValid)

        let invalid = ValidationUtils.maxLength("これは長すぎるテキストです", maxLength: 5, fieldName: "メモ")
        XCTAssertFalse(invalid.isValid)
    }

    func testEmailValidation() {
        let valid = ValidationUtils.email("test@example.com")
        XCTAssertTrue(valid.isValid)

        let invalid = ValidationUtils.email("invalid-email")
        XCTAssertFalse(invalid.isValid)

        let empty = ValidationUtils.email("")
        XCTAssertFalse(empty.isValid)
    }

    func testDisplayNameValidation() {
        let valid = ValidationUtils.displayName("ユーザー名")
        XCTAssertTrue(valid.isValid)

        let tooLong = ValidationUtils.displayName("これは非常に長い表示名でテスト用です")
        XCTAssertFalse(tooLong.isValid)

        let withInvalidChars = ValidationUtils.displayName("<script>")
        XCTAssertFalse(withInvalidChars.isValid)
    }

    // MARK: - AppLimits Tests

    func testRecordLimits() {
        XCTAssertEqual(AppLimits.Record.dailyLimit(for: .free), 5)
        XCTAssertEqual(AppLimits.Record.dailyLimit(for: .premium), .max)
    }

    func testDiaryLimits() {
        XCTAssertEqual(AppLimits.Diary.dailyLimit(for: .free), 3)
        XCTAssertEqual(AppLimits.Diary.maxImages(for: .free), 1)
        XCTAssertEqual(AppLimits.Diary.maxImages(for: .premium), 5)
    }

    func testLimitCheckResult() {
        let withinLimit = AppLimits.LimitCheckResult(currentCount: 3, limit: 5)
        XCTAssertTrue(withinLimit.isWithinLimit)
        XCTAssertEqual(withinLimit.remaining, 2)
        XCTAssertNil(withinLimit.limitReachedMessage)

        let atLimit = AppLimits.LimitCheckResult(currentCount: 5, limit: 5)
        XCTAssertFalse(atLimit.isWithinLimit)
        XCTAssertEqual(atLimit.remaining, 0)
        XCTAssertNotNil(atLimit.limitReachedMessage)
    }

    // MARK: - AppError Tests

    func testAppErrorMessages() {
        let noConnection = AppError.noConnection
        XCTAssertEqual(noConnection.errorDescription, "インターネット接続がありません")
        XCTAssertTrue(noConnection.isRetryable)

        let unauthorized = AppError.unauthorized
        XCTAssertEqual(unauthorized.errorDescription, "認証が必要です")
        XCTAssertFalse(unauthorized.isRetryable)

        let notFound = AppError.notFound(entity: "記録")
        XCTAssertEqual(notFound.errorDescription, "記録が見つかりません")
    }

    func testAppErrorFromHTTPStatus() {
        let unauthorized = AppError.fromHTTPStatus(401)
        XCTAssertEqual(unauthorized, .unauthorized)

        let notFound = AppError.fromHTTPStatus(404)
        if case .notFound = notFound {
            // OK
        } else {
            XCTFail("Expected notFound error")
        }

        let serverError = AppError.fromHTTPStatus(500, message: "Internal Server Error")
        if case .serverError(let code, _) = serverError {
            XCTAssertEqual(code, 500)
        } else {
            XCTFail("Expected serverError")
        }
    }

    // MARK: - String Extension Tests

    func testStringTrimmed() {
        XCTAssertEqual("  test  ".trimmed, "test")
        XCTAssertEqual("\n\ttest\n".trimmed, "test")
    }

    func testStringIsBlank() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("   ".isBlank)
        XCTAssertFalse("test".isBlank)
    }

    func testOptionalStringExtensions() {
        let nilString: String? = nil
        XCTAssertTrue(nilString.isNilOrEmpty)
        XCTAssertTrue(nilString.isNilOrBlank)

        let emptyString: String? = ""
        XCTAssertTrue(emptyString.isNilOrEmpty)
        XCTAssertNil(emptyString.nilIfEmpty)

        let blankString: String? = "   "
        XCTAssertFalse(blankString.isNilOrEmpty)
        XCTAssertTrue(blankString.isNilOrBlank)
        XCTAssertNil(blankString.nilIfBlank)

        let validString: String? = "test"
        XCTAssertFalse(validString.isNilOrEmpty)
        XCTAssertEqual(validString.nilIfEmpty, "test")
    }
}
