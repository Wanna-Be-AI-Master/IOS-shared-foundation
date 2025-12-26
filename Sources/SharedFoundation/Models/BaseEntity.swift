import Foundation

// MARK: - BaseEntity

/// 全エンティティの基底プロトコル
/// すべてのドメインエンティティはこのプロトコルに準拠する
public protocol BaseEntity: Identifiable, Codable, Equatable, Sendable {
    /// 一意識別子
    var id: UUID { get }

    /// 作成日時
    var createdAt: Date { get }

    /// 更新日時
    var updatedAt: Date { get }
}

// MARK: - SyncableEntity

/// 同期可能なエンティティプロトコル
/// オフラインファースト機能をサポートするエンティティ用
public protocol SyncableEntity: BaseEntity {
    /// 同期状態
    var syncStatus: SyncStatus { get set }

    /// 最後の同期日時
    var lastSyncedAt: Date? { get set }
}

// MARK: - SyncStatus

/// 同期状態
public enum SyncStatus: String, Codable, Sendable {
    /// 同期済み
    case synced

    /// 同期待ち（ローカルで変更あり）
    case pending

    /// 同期中
    case syncing

    /// 同期エラー
    case error

    /// 表示用テキスト
    public var displayText: String {
        switch self {
        case .synced:
            return "同期済み"
        case .pending:
            return "同期待ち"
        case .syncing:
            return "同期中..."
        case .error:
            return "同期エラー"
        }
    }

    /// アイコン名（SF Symbols）
    public var iconName: String {
        switch self {
        case .synced:
            return "checkmark.circle.fill"
        case .pending:
            return "clock.fill"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - SoftDeletable

/// 論理削除可能なエンティティプロトコル
public protocol SoftDeletable {
    /// 削除日時（nilの場合は削除されていない）
    var deletedAt: Date? { get set }

    /// 削除されているかどうか
    var isDeleted: Bool { get }
}

extension SoftDeletable {
    public var isDeleted: Bool {
        deletedAt != nil
    }
}
