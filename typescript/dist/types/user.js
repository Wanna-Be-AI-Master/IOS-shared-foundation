/**
 * ユーザー関連の型定義
 * 両アプリで共通して使用するユーザー基本情報
 */
// ========================================
// ユーティリティ型
// ========================================
/**
 * プレミアムが有効かどうかを判定
 */
export function isPremiumActive(info) {
    if (!info.isPremium)
        return false;
    if (!info.premiumExpiresAt)
        return true;
    return info.premiumExpiresAt > new Date();
}
/**
 * 表示名またはデフォルト名を取得
 */
export function getDisplayNameOrDefault(displayName, defaultName = 'ゲスト') {
    return displayName?.trim() || defaultName;
}
//# sourceMappingURL=user.js.map