import Foundation
import Supabase

// MARK: - AppError

/// アプリ共通エラー
/// 両アプリで統一したエラーハンドリングを提供
public enum AppError: LocalizedError, Equatable, Sendable {

    // MARK: - Network Errors

    /// ネットワーク接続なし
    case noConnection

    /// タイムアウト
    case timeout

    /// サーバーエラー
    case serverError(statusCode: Int, message: String?)

    /// 不正なレスポンス
    case invalidResponse

    // MARK: - Authentication Errors

    /// 未認証
    case unauthorized

    /// セッション期限切れ
    case sessionExpired

    /// Apple Sign-In 失敗
    case appleSignInFailed(reason: String)

    /// ユーザーが見つからない
    case userNotFound

    // MARK: - Data Errors

    /// データが見つからない
    case notFound(entity: String)

    /// 作成失敗
    case createFailed(entity: String)

    /// 更新失敗
    case updateFailed(entity: String)

    /// 削除失敗
    case deleteFailed(entity: String)

    /// 重複データ
    case duplicateEntry(entity: String)

    // MARK: - Validation Errors

    /// バリデーションエラー
    case validationFailed(field: String, reason: String)

    /// 入力値が不正
    case invalidInput(message: String)

    // MARK: - Storage Errors

    /// ストレージエラー
    case storageFailed(reason: String)

    /// ファイルが大きすぎる
    case fileTooLarge(maxSize: Int)

    /// サポートされていないファイル形式
    case unsupportedFileType

    // MARK: - Premium Errors

    /// プレミアム機能へのアクセス制限
    case premiumRequired

    /// 購入失敗
    case purchaseFailed(reason: String)

    /// 購入復元失敗
    case restoreFailed(reason: String)

    // MARK: - Sync Errors

    /// 同期失敗
    case syncFailed(reason: String)

    /// 競合発生
    case conflictDetected

    // MARK: - Unknown

    /// 不明なエラー
    case unknown(message: String)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        // Network
        case .noConnection:
            return "インターネット接続がありません"
        case .timeout:
            return "接続がタイムアウトしました"
        case .serverError(let statusCode, let message):
            return message ?? "サーバーエラーが発生しました（\(statusCode)）"
        case .invalidResponse:
            return "サーバーからの応答が不正です"

        // Authentication
        case .unauthorized:
            return "認証が必要です"
        case .sessionExpired:
            return "セッションが期限切れです。再度ログインしてください"
        case .appleSignInFailed(let reason):
            return "Apple IDでのログインに失敗しました: \(reason)"
        case .userNotFound:
            return "ユーザーが見つかりません"

        // Data
        case .notFound(let entity):
            return "\(entity)が見つかりません"
        case .createFailed(let entity):
            return "\(entity)の作成に失敗しました"
        case .updateFailed(let entity):
            return "\(entity)の更新に失敗しました"
        case .deleteFailed(let entity):
            return "\(entity)の削除に失敗しました"
        case .duplicateEntry(let entity):
            return "\(entity)はすでに存在します"

        // Validation
        case .validationFailed(let field, let reason):
            return "\(field): \(reason)"
        case .invalidInput(let message):
            return message

        // Storage
        case .storageFailed(let reason):
            return "ストレージエラー: \(reason)"
        case .fileTooLarge(let maxSize):
            return "ファイルサイズが大きすぎます（最大: \(maxSize / 1024 / 1024)MB）"
        case .unsupportedFileType:
            return "サポートされていないファイル形式です"

        // Premium
        case .premiumRequired:
            return "この機能はプレミアム会員限定です"
        case .purchaseFailed(let reason):
            return "購入に失敗しました: \(reason)"
        case .restoreFailed(let reason):
            return "購入の復元に失敗しました: \(reason)"

        // Sync
        case .syncFailed(let reason):
            return "同期に失敗しました: \(reason)"
        case .conflictDetected:
            return "データの競合が検出されました"

        // Unknown
        case .unknown(let message):
            return message
        }
    }

    /// ユーザーに表示するタイトル
    public var displayTitle: String {
        switch self {
        case .noConnection, .timeout, .serverError, .invalidResponse:
            return "通信エラー"
        case .unauthorized, .sessionExpired, .appleSignInFailed, .userNotFound:
            return "認証エラー"
        case .notFound, .createFailed, .updateFailed, .deleteFailed, .duplicateEntry:
            return "データエラー"
        case .validationFailed, .invalidInput:
            return "入力エラー"
        case .storageFailed, .fileTooLarge, .unsupportedFileType:
            return "ストレージエラー"
        case .premiumRequired, .purchaseFailed, .restoreFailed:
            return "購入エラー"
        case .syncFailed, .conflictDetected:
            return "同期エラー"
        case .unknown:
            return "エラー"
        }
    }

    /// 再試行可能かどうか
    public var isRetryable: Bool {
        switch self {
        case .noConnection, .timeout, .serverError, .syncFailed:
            return true
        default:
            return false
        }
    }

    // MARK: - Equatable

    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}

// MARK: - Error Mapping

extension AppError {

    /// Supabaseエラーから変換
    public static func from(_ error: Error) -> AppError {
        // URLError
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noConnection
            case .timedOut:
                return .timeout
            default:
                return .serverError(statusCode: urlError.errorCode, message: urlError.localizedDescription)
            }
        }

        // Supabase AuthError
        if let authError = error as? AuthError {
            switch authError {
            case .sessionNotFound:
                return .sessionExpired
            default:
                return .appleSignInFailed(reason: authError.localizedDescription)
            }
        }

        // Generic error
        return .unknown(message: error.localizedDescription)
    }

    /// HTTPステータスコードから変換
    public static func fromHTTPStatus(_ statusCode: Int, message: String? = nil) -> AppError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .premiumRequired
        case 404:
            return .notFound(entity: "リソース")
        case 409:
            return .duplicateEntry(entity: "データ")
        case 422:
            return .invalidInput(message: message ?? "入力値が不正です")
        case 500...599:
            return .serverError(statusCode: statusCode, message: message)
        default:
            return .unknown(message: message ?? "不明なエラー（\(statusCode)）")
        }
    }
}

// MARK: - Result Extension

extension Result where Failure == AppError {

    /// エラーメッセージを取得
    public var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error.errorDescription
        }
    }
}
