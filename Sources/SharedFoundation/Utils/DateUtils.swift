import Foundation

// MARK: - DateUtils

/// 日付ユーティリティ
/// 日本語フォーマットを統一
public enum DateUtils {

    // MARK: - Shared Formatters

    /// ISO8601フォーマッター（API通信用）
    public static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    /// 日本語カレンダー
    public static let japaneseCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }()

    // MARK: - Format Patterns

    /// 日付フォーマットパターン
    public enum Format: String {
        /// 年月日（2024年1月15日）
        case fullDate = "yyyy年M月d日"

        /// 年月（2024年1月）
        case yearMonth = "yyyy年M月"

        /// 月日（1月15日）
        case monthDay = "M月d日"

        /// 曜日付き（1月15日（月））
        case monthDayWeekday = "M月d日（E）"

        /// 時刻（14:30）
        case time = "HH:mm"

        /// 日時（1月15日 14:30）
        case dateTime = "M月d日 HH:mm"

        /// フル日時（2024年1月15日 14:30）
        case fullDateTime = "yyyy年M月d日 HH:mm"

        /// 短い形式（1/15）
        case shortDate = "M/d"

        /// API用（2024-01-15）
        case apiDate = "yyyy-MM-dd"

        /// API用日時（2024-01-15T14:30:00）
        case apiDateTime = "yyyy-MM-dd'T'HH:mm:ss"
    }

    // MARK: - Formatting

    /// 日付をフォーマット
    /// - Parameters:
    ///   - date: フォーマットする日付
    ///   - format: フォーマットパターン
    /// - Returns: フォーマットされた文字列
    public static func format(_ date: Date, format: Format) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }

    /// 相対的な日付表現を取得
    /// - Parameter date: 対象の日付
    /// - Returns: 「今日」「昨日」「3日前」など
    public static func relativeFormat(_ date: Date) -> String {
        let calendar = japaneseCalendar
        let now = Date()

        // 今日
        if calendar.isDateInToday(date) {
            return "今日"
        }

        // 昨日
        if calendar.isDateInYesterday(date) {
            return "昨日"
        }

        // 明日
        if calendar.isDateInTomorrow(date) {
            return "明日"
        }

        // 今週
        if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let weekday = calendar.component(.weekday, from: date)
            let weekdaySymbols = ["", "日", "月", "火", "水", "木", "金", "土"]
            return "\(weekdaySymbols[weekday])曜日"
        }

        // 今年
        if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            return format(date, format: .monthDay)
        }

        // それ以外
        return format(date, format: .fullDate)
    }

    /// 経過時間を表現
    /// - Parameter date: 対象の日付
    /// - Returns: 「たった今」「5分前」「2時間前」など
    public static func timeAgo(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        // 未来の日付
        if interval < 0 {
            return relativeFormat(date)
        }

        // 1分未満
        if interval < 60 {
            return "たった今"
        }

        // 1時間未満
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)分前"
        }

        // 24時間未満
        if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)時間前"
        }

        // 7日未満
        if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)日前"
        }

        // それ以外
        return relativeFormat(date)
    }

    // MARK: - Parsing

    /// 文字列から日付をパース
    /// - Parameters:
    ///   - string: パースする文字列
    ///   - format: フォーマットパターン
    /// - Returns: パースされた日付（失敗時はnil）
    public static func parse(_ string: String, format: Format) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.dateFormat = format.rawValue
        return formatter.date(from: string)
    }

    /// ISO8601文字列から日付をパース
    /// - Parameter string: ISO8601形式の文字列
    /// - Returns: パースされた日付（失敗時はnil）
    public static func parseISO8601(_ string: String) -> Date? {
        iso8601Formatter.date(from: string)
    }

    // MARK: - Calculations

    /// 今日の開始時刻を取得
    public static func startOfToday() -> Date {
        japaneseCalendar.startOfDay(for: Date())
    }

    /// 今日の終了時刻を取得
    public static func endOfToday() -> Date {
        let start = startOfToday()
        return japaneseCalendar.date(byAdding: .day, value: 1, to: start)!.addingTimeInterval(-1)
    }

    /// 今月の開始日を取得
    public static func startOfMonth(for date: Date = Date()) -> Date {
        let components = japaneseCalendar.dateComponents([.year, .month], from: date)
        return japaneseCalendar.date(from: components)!
    }

    /// 今月の終了日を取得
    public static func endOfMonth(for date: Date = Date()) -> Date {
        let start = startOfMonth(for: date)
        return japaneseCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
    }

    /// 今週の開始日を取得（月曜始まり）
    public static func startOfWeek(for date: Date = Date()) -> Date {
        var calendar = japaneseCalendar
        calendar.firstWeekday = 2 // 月曜始まり
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }

    /// 日数差を計算
    /// - Parameters:
    ///   - from: 開始日
    ///   - to: 終了日
    /// - Returns: 日数差
    public static func daysBetween(from: Date, to: Date) -> Int {
        let fromStart = japaneseCalendar.startOfDay(for: from)
        let toStart = japaneseCalendar.startOfDay(for: to)
        let components = japaneseCalendar.dateComponents([.day], from: fromStart, to: toStart)
        return components.day ?? 0
    }

    /// 連続日数を計算
    /// - Parameter dates: 日付の配列（ソート済み）
    /// - Returns: 今日からの連続日数
    public static func calculateStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }

        let sortedDates = dates.map { japaneseCalendar.startOfDay(for: $0) }
            .sorted(by: >)

        let today = startOfToday()
        var streak = 0
        var expectedDate = today

        for date in sortedDates {
            if date == expectedDate {
                streak += 1
                expectedDate = japaneseCalendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if date < expectedDate {
                // 日付が飛んでいる場合、昨日から始まる連続をチェック
                if streak == 0 {
                    let yesterday = japaneseCalendar.date(byAdding: .day, value: -1, to: today)!
                    if date == yesterday {
                        expectedDate = yesterday
                        continue
                    }
                }
                break
            }
        }

        return streak
    }

    // MARK: - Comparison

    /// 同じ日かどうか
    public static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        japaneseCalendar.isDate(date1, inSameDayAs: date2)
    }

    /// 今日かどうか
    public static func isToday(_ date: Date) -> Bool {
        japaneseCalendar.isDateInToday(date)
    }

    /// 今週かどうか
    public static func isThisWeek(_ date: Date) -> Bool {
        japaneseCalendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// 今月かどうか
    public static func isThisMonth(_ date: Date) -> Bool {
        japaneseCalendar.isDate(date, equalTo: Date(), toGranularity: .month)
    }
}

// MARK: - Date Extension

extension Date {

    /// 日本語フォーマット
    public func formatted(_ format: DateUtils.Format) -> String {
        DateUtils.format(self, format: format)
    }

    /// 相対表現
    public var relativeFormatted: String {
        DateUtils.relativeFormat(self)
    }

    /// 経過時間表現
    public var timeAgo: String {
        DateUtils.timeAgo(self)
    }

    /// 今日かどうか
    public var isToday: Bool {
        DateUtils.isToday(self)
    }

    /// 今週かどうか
    public var isThisWeek: Bool {
        DateUtils.isThisWeek(self)
    }

    /// 今月かどうか
    public var isThisMonth: Bool {
        DateUtils.isThisMonth(self)
    }

    /// 日の開始時刻
    public var startOfDay: Date {
        DateUtils.japaneseCalendar.startOfDay(for: self)
    }
}
