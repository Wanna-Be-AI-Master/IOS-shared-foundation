import Foundation

// MARK: - AppLimits

/// アプリ制限値
/// 無料/プレミアム会員の機能制限を統一管理
public enum AppLimits {

    // MARK: - User Tiers

    /// ユーザーティア
    public enum Tier: String, CaseIterable, Sendable {
        case free = "無料"
        case premium = "プレミアム"
    }

    // MARK: - Storage Limits

    /// ストレージ制限
    public enum Storage {
        /// 画像の最大ファイルサイズ（バイト）
        public static let maxImageSize: Int = 5 * 1024 * 1024 // 5MB

        /// 画像の圧縮品質
        public static let imageCompressionQuality: CGFloat = 0.8

        /// 画像の最大幅/高さ
        public static let maxImageDimension: Int = 1920

        /// サムネイルサイズ
        public static let thumbnailSize: Int = 200

        /// 対応画像フォーマット
        public static let supportedImageFormats: [String] = ["jpg", "jpeg", "png", "heic"]
    }

    // MARK: - Record Limits (Karoyaka)

    /// 記録制限（かろやか専用）
    public enum Record {
        /// 無料会員の1日あたりの記録上限
        public static let dailyLimitFree: Int = 5

        /// プレミアム会員の1日あたりの記録上限
        public static let dailyLimitPremium: Int = .max

        /// メモの最大文字数
        public static let maxMemoLength: Int = 500

        /// 履歴保持期間（無料・日数）
        public static let historyRetentionFree: Int = 30

        /// 履歴保持期間（プレミアム・日数）
        public static let historyRetentionPremium: Int = .max

        /// ティアに応じた1日の記録上限を取得
        public static func dailyLimit(for tier: Tier) -> Int {
            switch tier {
            case .free:
                return dailyLimitFree
            case .premium:
                return dailyLimitPremium
            }
        }

        /// ティアに応じた履歴保持期間を取得
        public static func historyRetention(for tier: Tier) -> Int {
            switch tier {
            case .free:
                return historyRetentionFree
            case .premium:
                return historyRetentionPremium
            }
        }
    }

    // MARK: - Diary Limits (Musubi)

    /// 日記制限（むすび専用）
    public enum Diary {
        /// 無料会員の1日あたりの日記上限
        public static let dailyLimitFree: Int = 3

        /// プレミアム会員の1日あたりの日記上限
        public static let dailyLimitPremium: Int = .max

        /// 日記本文の最大文字数
        public static let maxContentLength: Int = 2000

        /// 日記タイトルの最大文字数
        public static let maxTitleLength: Int = 50

        /// 添付画像の最大枚数（無料）
        public static let maxImagesFree: Int = 1

        /// 添付画像の最大枚数（プレミアム）
        public static let maxImagesPremium: Int = 5

        /// ティアに応じた1日の日記上限を取得
        public static func dailyLimit(for tier: Tier) -> Int {
            switch tier {
            case .free:
                return dailyLimitFree
            case .premium:
                return dailyLimitPremium
            }
        }

        /// ティアに応じた添付画像上限を取得
        public static func maxImages(for tier: Tier) -> Int {
            switch tier {
            case .free:
                return maxImagesFree
            case .premium:
                return maxImagesPremium
            }
        }
    }

    // MARK: - Pair Limits (Musubi)

    /// ペア制限（むすび専用）
    public enum Pair {
        /// 無料会員の最大ペア数
        public static let maxPairsFree: Int = 1

        /// プレミアム会員の最大ペア数
        public static let maxPairsPremium: Int = 5

        /// 招待コードの有効期限（時間）
        public static let inviteCodeExpiration: Int = 24

        /// ティアに応じた最大ペア数を取得
        public static func maxPairs(for tier: Tier) -> Int {
            switch tier {
            case .free:
                return maxPairsFree
            case .premium:
                return maxPairsPremium
            }
        }
    }

    // MARK: - Badge Limits

    /// バッジ制限
    public enum Badge {
        /// バッジ達成チェックの間隔（秒）
        public static let checkInterval: TimeInterval = 60

        /// 新規バッジ表示時間（秒）
        public static let displayDuration: TimeInterval = 3
    }

    // MARK: - Sync Limits

    /// 同期制限
    public enum Sync {
        /// 同期間隔（秒）
        public static let interval: TimeInterval = 300 // 5分

        /// バックグラウンド同期間隔（秒）
        public static let backgroundInterval: TimeInterval = 900 // 15分

        /// 同期リトライ回数
        public static let maxRetries: Int = 3

        /// リトライ間隔（秒）
        public static let retryInterval: TimeInterval = 5

        /// オフラインキューの最大サイズ
        public static let maxQueueSize: Int = 100
    }

    // MARK: - Notification Limits

    /// 通知制限
    public enum Notification {
        /// デフォルト通知時間（時）
        public static let defaultHour: Int = 20

        /// デフォルト通知時間（分）
        public static let defaultMinute: Int = 0

        /// 最大スケジュール通知数
        public static let maxScheduled: Int = 64
    }

    // MARK: - API Limits

    /// API制限
    public enum API {
        /// ページネーションのデフォルトサイズ
        public static let defaultPageSize: Int = 20

        /// ページネーションの最大サイズ
        public static let maxPageSize: Int = 100

        /// リクエストタイムアウト（秒）
        public static let requestTimeout: TimeInterval = 30

        /// レート制限（リクエスト/分）
        public static let rateLimit: Int = 60
    }

    // MARK: - Cache Limits

    /// キャッシュ制限
    public enum Cache {
        /// メモリキャッシュの最大サイズ（バイト）
        public static let maxMemorySize: Int = 50 * 1024 * 1024 // 50MB

        /// ディスクキャッシュの最大サイズ（バイト）
        public static let maxDiskSize: Int = 200 * 1024 * 1024 // 200MB

        /// キャッシュの有効期限（秒）
        public static let expiration: TimeInterval = 86400 * 7 // 7日
    }
}

// MARK: - Limit Check Extensions

extension AppLimits {

    /// 制限チェック結果
    public struct LimitCheckResult: Sendable {
        /// 制限内かどうか
        public let isWithinLimit: Bool

        /// 現在の使用量
        public let currentCount: Int

        /// 制限値
        public let limit: Int

        /// 残り
        public var remaining: Int {
            max(0, limit - currentCount)
        }

        /// 使用率（0.0〜1.0）
        public var usageRatio: Double {
            guard limit > 0 else { return 0 }
            return min(1.0, Double(currentCount) / Double(limit))
        }

        /// 制限到達メッセージ
        public var limitReachedMessage: String? {
            guard !isWithinLimit else { return nil }
            return "本日の上限（\(limit)件）に達しました"
        }

        public init(currentCount: Int, limit: Int) {
            self.currentCount = currentCount
            self.limit = limit
            self.isWithinLimit = limit == .max || currentCount < limit
        }
    }
}
