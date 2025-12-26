import Foundation

// MARK: - ValidationUtils

/// バリデーションユーティリティ
/// 入力検証規則を統一
public enum ValidationUtils {

    // MARK: - Validation Result

    /// バリデーション結果
    public struct ValidationResult: Sendable {
        /// 有効かどうか
        public let isValid: Bool

        /// エラーメッセージ（無効な場合）
        public let errorMessage: String?

        /// 有効な結果を作成
        public static var valid: ValidationResult {
            ValidationResult(isValid: true, errorMessage: nil)
        }

        /// 無効な結果を作成
        public static func invalid(_ message: String) -> ValidationResult {
            ValidationResult(isValid: false, errorMessage: message)
        }

        public init(isValid: Bool, errorMessage: String? = nil) {
            self.isValid = isValid
            self.errorMessage = errorMessage
        }
    }

    // MARK: - String Validation

    /// 空文字チェック
    /// - Parameters:
    ///   - value: 検証する文字列
    ///   - fieldName: フィールド名（エラーメッセージ用）
    /// - Returns: バリデーション結果
    public static func notEmpty(_ value: String, fieldName: String) -> ValidationResult {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .invalid("\(fieldName)を入力してください")
        }
        return .valid
    }

    /// 文字数制限チェック
    /// - Parameters:
    ///   - value: 検証する文字列
    ///   - maxLength: 最大文字数
    ///   - fieldName: フィールド名
    /// - Returns: バリデーション結果
    public static func maxLength(_ value: String, maxLength: Int, fieldName: String) -> ValidationResult {
        if value.count > maxLength {
            return .invalid("\(fieldName)は\(maxLength)文字以内で入力してください")
        }
        return .valid
    }

    /// 文字数範囲チェック
    /// - Parameters:
    ///   - value: 検証する文字列
    ///   - minLength: 最小文字数
    ///   - maxLength: 最大文字数
    ///   - fieldName: フィールド名
    /// - Returns: バリデーション結果
    public static func lengthRange(_ value: String, minLength: Int, maxLength: Int, fieldName: String) -> ValidationResult {
        if value.count < minLength {
            return .invalid("\(fieldName)は\(minLength)文字以上で入力してください")
        }
        if value.count > maxLength {
            return .invalid("\(fieldName)は\(maxLength)文字以内で入力してください")
        }
        return .valid
    }

    // MARK: - Email Validation

    /// メールアドレス形式チェック
    /// - Parameter email: メールアドレス
    /// - Returns: バリデーション結果
    public static func email(_ email: String) -> ValidationResult {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .invalid("メールアドレスを入力してください")
        }

        let emailPattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let regex = try? NSRegularExpression(pattern: emailPattern)
        let range = NSRange(trimmed.startIndex..., in: trimmed)

        if regex?.firstMatch(in: trimmed, range: range) == nil {
            return .invalid("正しいメールアドレス形式で入力してください")
        }

        return .valid
    }

    // MARK: - Display Name Validation

    /// 表示名チェック
    /// - Parameters:
    ///   - name: 表示名
    ///   - minLength: 最小文字数（デフォルト: 1）
    ///   - maxLength: 最大文字数（デフォルト: 20）
    /// - Returns: バリデーション結果
    public static func displayName(_ name: String, minLength: Int = 1, maxLength: Int = 20) -> ValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .invalid("表示名を入力してください")
        }

        if trimmed.count < minLength {
            return .invalid("表示名は\(minLength)文字以上で入力してください")
        }

        if trimmed.count > maxLength {
            return .invalid("表示名は\(maxLength)文字以内で入力してください")
        }

        // 不正な文字のチェック
        let invalidCharacters = CharacterSet(charactersIn: "<>\"'&\\")
        if trimmed.unicodeScalars.contains(where: { invalidCharacters.contains($0) }) {
            return .invalid("表示名に使用できない文字が含まれています")
        }

        return .valid
    }

    // MARK: - Memo/Content Validation

    /// メモ・本文チェック
    /// - Parameters:
    ///   - content: 内容
    ///   - maxLength: 最大文字数
    ///   - fieldName: フィールド名
    ///   - required: 必須かどうか
    /// - Returns: バリデーション結果
    public static func content(
        _ content: String,
        maxLength: Int,
        fieldName: String = "内容",
        required: Bool = false
    ) -> ValidationResult {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if required && trimmed.isEmpty {
            return .invalid("\(fieldName)を入力してください")
        }

        if trimmed.count > maxLength {
            return .invalid("\(fieldName)は\(maxLength)文字以内で入力してください")
        }

        return .valid
    }

    // MARK: - Image Validation

    /// 画像サイズチェック
    /// - Parameters:
    ///   - dataSize: データサイズ（バイト）
    ///   - maxSize: 最大サイズ（バイト）
    /// - Returns: バリデーション結果
    public static func imageSize(_ dataSize: Int, maxSize: Int = AppLimits.Storage.maxImageSize) -> ValidationResult {
        if dataSize > maxSize {
            let maxMB = maxSize / 1024 / 1024
            return .invalid("画像サイズは\(maxMB)MB以内にしてください")
        }
        return .valid
    }

    /// 画像形式チェック
    /// - Parameter filename: ファイル名
    /// - Returns: バリデーション結果
    public static func imageFormat(_ filename: String) -> ValidationResult {
        let ext = (filename as NSString).pathExtension.lowercased()

        if !AppLimits.Storage.supportedImageFormats.contains(ext) {
            let formats = AppLimits.Storage.supportedImageFormats.joined(separator: ", ")
            return .invalid("対応形式: \(formats)")
        }

        return .valid
    }

    // MARK: - Invite Code Validation

    /// 招待コードチェック
    /// - Parameter code: 招待コード
    /// - Returns: バリデーション結果
    public static func inviteCode(_ code: String) -> ValidationResult {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if trimmed.isEmpty {
            return .invalid("招待コードを入力してください")
        }

        // 形式チェック（例: 6文字の英数字）
        let pattern = #"^[A-Z0-9]{6}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(trimmed.startIndex..., in: trimmed)

        if regex?.firstMatch(in: trimmed, range: range) == nil {
            return .invalid("招待コードは6文字の英数字です")
        }

        return .valid
    }

    // MARK: - Combined Validation

    /// 複数のバリデーションを実行
    /// - Parameter validations: バリデーション関数の配列
    /// - Returns: 最初に失敗したバリデーション結果、または成功
    public static func combine(_ validations: [() -> ValidationResult]) -> ValidationResult {
        for validation in validations {
            let result = validation()
            if !result.isValid {
                return result
            }
        }
        return .valid
    }

    /// 複数のバリデーション結果を合成
    /// - Parameter results: バリデーション結果の配列
    /// - Returns: 全て成功なら成功、そうでなければ最初のエラー
    public static func combineResults(_ results: [ValidationResult]) -> ValidationResult {
        for result in results {
            if !result.isValid {
                return result
            }
        }
        return .valid
    }
}

// MARK: - String Extension

extension String {

    /// 空白・改行をトリム
    public var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 空文字かどうか（トリム後）
    public var isBlank: Bool {
        trimmed.isEmpty
    }

    /// 有効な表示名かどうか
    public var isValidDisplayName: Bool {
        ValidationUtils.displayName(self).isValid
    }

    /// 有効なメールアドレスかどうか
    public var isValidEmail: Bool {
        ValidationUtils.email(self).isValid
    }

    /// 文字数制限チェック
    public func isWithinLength(_ maxLength: Int) -> Bool {
        count <= maxLength
    }
}

// MARK: - Optional String Extension

extension Optional where Wrapped == String {

    /// nilまたは空文字かどうか
    public var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    /// nilまたは空白のみかどうか
    public var isNilOrBlank: Bool {
        self?.isBlank ?? true
    }

    /// 空文字ならnilを返す
    public var nilIfEmpty: String? {
        guard let value = self, !value.isEmpty else { return nil }
        return value
    }

    /// 空白のみならnilを返す
    public var nilIfBlank: String? {
        guard let value = self, !value.isBlank else { return nil }
        return value
    }
}
