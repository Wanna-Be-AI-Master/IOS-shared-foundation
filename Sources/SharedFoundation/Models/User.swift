import Foundation

// MARK: - User

/// 共通ユーザーモデル
/// 両アプリで共有するユーザー情報
public struct User: BaseEntity, SyncableEntity {

    // MARK: - Properties

    /// ユーザーID
    public let id: UUID

    /// Apple ID（Sign in with Appleで取得）
    public let appleId: String?

    /// メールアドレス
    public let email: String?

    /// 表示名
    public var displayName: String

    /// アバター画像URL
    public var avatarUrl: String?

    /// プレミアム会員かどうか
    public var isPremium: Bool

    /// プレミアム有効期限
    public var premiumExpiresAt: Date?

    /// 作成日時
    public let createdAt: Date

    /// 更新日時
    public var updatedAt: Date

    /// 同期状態
    public var syncStatus: SyncStatus

    /// 最後の同期日時
    public var lastSyncedAt: Date?

    // MARK: - Computed Properties

    /// プレミアムが有効かどうか
    public var isPremiumActive: Bool {
        guard isPremium else { return false }
        guard let expiresAt = premiumExpiresAt else { return true }
        return expiresAt > Date()
    }

    /// 認証済みかどうか
    public var isAuthenticated: Bool {
        appleId != nil
    }

    /// 匿名ユーザーかどうか
    public var isAnonymous: Bool {
        appleId == nil
    }

    /// 表示用の名前（未設定の場合はデフォルト名）
    public var displayNameOrDefault: String {
        displayName.isEmpty ? "ゲスト" : displayName
    }

    // MARK: - Initializer

    public init(
        id: UUID = UUID(),
        appleId: String? = nil,
        email: String? = nil,
        displayName: String = "",
        avatarUrl: String? = nil,
        isPremium: Bool = false,
        premiumExpiresAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncStatus: SyncStatus = .pending,
        lastSyncedAt: Date? = nil
    ) {
        self.id = id
        self.appleId = appleId
        self.email = email
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.isPremium = isPremium
        self.premiumExpiresAt = premiumExpiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
        self.lastSyncedAt = lastSyncedAt
    }

    // MARK: - Factory Methods

    /// 匿名ユーザーを作成
    public static func createAnonymous() -> User {
        User(
            id: UUID(),
            displayName: "ゲスト",
            syncStatus: .pending
        )
    }
}

// MARK: - UserDTO

/// ユーザーDTO（API通信用）
public struct UserDTO: Codable, Sendable {

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case email
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case isPremium = "is_premium"
        case premiumExpiresAt = "premium_expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - Properties

    public let id: UUID
    public let appleId: String?
    public let email: String?
    public let displayName: String?
    public let avatarUrl: String?
    public let isPremium: Bool?
    public let premiumExpiresAt: Date?
    public let createdAt: Date?
    public let updatedAt: Date?

    // MARK: - Initializer

    public init(
        id: UUID,
        appleId: String? = nil,
        email: String? = nil,
        displayName: String? = nil,
        avatarUrl: String? = nil,
        isPremium: Bool? = nil,
        premiumExpiresAt: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.appleId = appleId
        self.email = email
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.isPremium = isPremium
        self.premiumExpiresAt = premiumExpiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Conversion

    /// DTOからドメインモデルに変換
    public func toDomain() -> User {
        User(
            id: id,
            appleId: appleId,
            email: email,
            displayName: displayName ?? "",
            avatarUrl: avatarUrl,
            isPremium: isPremium ?? false,
            premiumExpiresAt: premiumExpiresAt,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            syncStatus: .synced,
            lastSyncedAt: Date()
        )
    }

    /// ドメインモデルからDTOに変換
    public static func fromDomain(_ user: User) -> UserDTO {
        UserDTO(
            id: user.id,
            appleId: user.appleId,
            email: user.email,
            displayName: user.displayName,
            avatarUrl: user.avatarUrl,
            isPremium: user.isPremium,
            premiumExpiresAt: user.premiumExpiresAt,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
        )
    }
}
