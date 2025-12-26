/**
 * 制限値定義
 * 無料/プレミアムプランの制限
 */
// ========================================
// プラン別制限
// ========================================
/**
 * 無料プランの制限
 */
export const FREE_LIMITS = {
    /** 最大アイテム数（月あたり、または総数） */
    maxItems: 50,
    /** アイテムあたりの最大写真数 */
    maxPhotosPerItem: 1,
    /** データ保持日数 */
    retentionDays: 30,
    /** 最大日記帳数（むすび用） */
    maxDiaries: 1,
};
/**
 * プレミアムプランの制限
 */
export const PREMIUM_LIMITS = {
    /** 最大アイテム数（-1 = 無制限） */
    maxItems: -1,
    /** アイテムあたりの最大写真数 */
    maxPhotosPerItem: 4,
    /** データ保持日数（-1 = 無制限） */
    retentionDays: -1,
    /** 最大日記帳数（-1 = 無制限） */
    maxDiaries: -1,
};
/**
 * 共通制限
 */
export const COMMON_LIMITS = {
    /** 表示名の最大文字数 */
    maxDisplayNameLength: 20,
    /** 本文の最大文字数 */
    maxContentLength: 10000,
    /** 招待コードの長さ */
    inviteCodeLength: 6,
    /** 画像の最大サイズ（ピクセル） */
    maxImageSize: 1024,
    /** 画像の圧縮品質 */
    imageQuality: 0.7,
};
/**
 * 制限値をまとめたオブジェクト
 */
export const LIMITS = {
    free: FREE_LIMITS,
    premium: PREMIUM_LIMITS,
    common: COMMON_LIMITS,
};
// ========================================
// ユーティリティ関数
// ========================================
/**
 * 制限に達しているかどうかを判定
 * @param current 現在の値
 * @param limit 制限値（-1 = 無制限）
 */
export function isLimitReached(current, limit) {
    if (limit === -1)
        return false; // 無制限
    return current >= limit;
}
/**
 * 残り数を取得
 * @param current 現在の値
 * @param limit 制限値（-1 = 無制限）
 */
export function getRemainingCount(current, limit) {
    if (limit === -1)
        return null; // 無制限
    return Math.max(0, limit - current);
}
/**
 * プランに応じた制限値を取得
 */
export function getLimitsForPlan(isPremium) {
    return isPremium ? PREMIUM_LIMITS : FREE_LIMITS;
}
//# sourceMappingURL=limits.js.map