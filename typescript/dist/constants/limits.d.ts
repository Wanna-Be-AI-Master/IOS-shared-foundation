/**
 * 制限値定義
 * 無料/プレミアムプランの制限
 */
/**
 * 無料プランの制限
 */
export declare const FREE_LIMITS: {
    /** 最大アイテム数（月あたり、または総数） */
    readonly maxItems: 50;
    /** アイテムあたりの最大写真数 */
    readonly maxPhotosPerItem: 1;
    /** データ保持日数 */
    readonly retentionDays: 30;
    /** 最大日記帳数（むすび用） */
    readonly maxDiaries: 1;
};
/**
 * プレミアムプランの制限
 */
export declare const PREMIUM_LIMITS: {
    /** 最大アイテム数（-1 = 無制限） */
    readonly maxItems: -1;
    /** アイテムあたりの最大写真数 */
    readonly maxPhotosPerItem: 4;
    /** データ保持日数（-1 = 無制限） */
    readonly retentionDays: -1;
    /** 最大日記帳数（-1 = 無制限） */
    readonly maxDiaries: -1;
};
/**
 * 共通制限
 */
export declare const COMMON_LIMITS: {
    /** 表示名の最大文字数 */
    readonly maxDisplayNameLength: 20;
    /** 本文の最大文字数 */
    readonly maxContentLength: 10000;
    /** 招待コードの長さ */
    readonly inviteCodeLength: 6;
    /** 画像の最大サイズ（ピクセル） */
    readonly maxImageSize: 1024;
    /** 画像の圧縮品質 */
    readonly imageQuality: 0.7;
};
/**
 * 制限値をまとめたオブジェクト
 */
export declare const LIMITS: {
    readonly free: {
        /** 最大アイテム数（月あたり、または総数） */
        readonly maxItems: 50;
        /** アイテムあたりの最大写真数 */
        readonly maxPhotosPerItem: 1;
        /** データ保持日数 */
        readonly retentionDays: 30;
        /** 最大日記帳数（むすび用） */
        readonly maxDiaries: 1;
    };
    readonly premium: {
        /** 最大アイテム数（-1 = 無制限） */
        readonly maxItems: -1;
        /** アイテムあたりの最大写真数 */
        readonly maxPhotosPerItem: 4;
        /** データ保持日数（-1 = 無制限） */
        readonly retentionDays: -1;
        /** 最大日記帳数（-1 = 無制限） */
        readonly maxDiaries: -1;
    };
    readonly common: {
        /** 表示名の最大文字数 */
        readonly maxDisplayNameLength: 20;
        /** 本文の最大文字数 */
        readonly maxContentLength: 10000;
        /** 招待コードの長さ */
        readonly inviteCodeLength: 6;
        /** 画像の最大サイズ（ピクセル） */
        readonly maxImageSize: 1024;
        /** 画像の圧縮品質 */
        readonly imageQuality: 0.7;
    };
};
export type FreeLimits = typeof FREE_LIMITS;
export type PremiumLimits = typeof PREMIUM_LIMITS;
export type CommonLimits = typeof COMMON_LIMITS;
export type Limits = typeof LIMITS;
/**
 * 制限に達しているかどうかを判定
 * @param current 現在の値
 * @param limit 制限値（-1 = 無制限）
 */
export declare function isLimitReached(current: number, limit: number): boolean;
/**
 * 残り数を取得
 * @param current 現在の値
 * @param limit 制限値（-1 = 無制限）
 */
export declare function getRemainingCount(current: number, limit: number): number | null;
/**
 * プランに応じた制限値を取得
 */
export declare function getLimitsForPlan(isPremium: boolean): FreeLimits | PremiumLimits;
//# sourceMappingURL=limits.d.ts.map