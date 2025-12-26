/**
 * 共通設定定義
 * タイムゾーン、アニメーション、画像設定など
 */
/** 日本タイムゾーン */
export declare const TIMEZONE = "Asia/Tokyo";
/** デフォルトロケール */
export declare const DEFAULT_LOCALE = "ja-JP";
/**
 * アニメーション時間（ミリ秒）
 */
export declare const ANIMATION: {
    /** 短い（ボタンプレスなど） */
    readonly short: 150;
    /** 標準（トランジションなど） */
    readonly standard: 300;
    /** 長い（ページ遷移など） */
    readonly long: 500;
};
/**
 * イージング
 */
export declare const EASING: {
    /** 標準 */
    readonly standard: "ease-out";
    /** 加速 */
    readonly accelerate: "ease-in";
    /** 減速 */
    readonly decelerate: "ease-out";
    /** 弾む */
    readonly bounce: "cubic-bezier(0.68, -0.55, 0.265, 1.55)";
};
/**
 * 画像設定
 */
export declare const IMAGE: {
    /** 最大サイズ（ピクセル） */
    readonly maxSize: 1024;
    /** 圧縮品質（0-1） */
    readonly quality: 0.7;
    /** サポートするフォーマット */
    readonly formats: readonly ["jpeg", "png", "webp"];
    /** サムネイルサイズ */
    readonly thumbnailSize: 200;
};
/**
 * 通知設定
 */
export declare const NOTIFICATION: {
    /** デフォルト通知時間 */
    readonly defaultTime: "21:00";
    /** 通知時間の選択肢 */
    readonly timeOptions: readonly ["07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"];
};
/**
 * ローカルストレージキー（共通）
 */
export declare const STORAGE_KEYS: {
    /** 初回起動フラグ */
    readonly hasLaunchedBefore: "hasLaunchedBefore";
    /** オンボーディング完了フラグ */
    readonly hasCompletedOnboarding: "hasCompletedOnboarding";
    /** カラースキーム */
    readonly colorScheme: "colorScheme";
    /** 最終同期日時 */
    readonly lastSyncTime: "lastSyncTime";
};
/**
 * 共通価格設定
 */
export declare const PRICING: {
    /** 月額プレミアム */
    readonly monthlyPremium: 380;
    /** 年額プレミアム（35%割引） */
    readonly yearlyPremium: 2980;
    /** 通貨 */
    readonly currency: "JPY";
};
export declare const CONFIG: {
    readonly timezone: "Asia/Tokyo";
    readonly locale: "ja-JP";
    readonly animation: {
        /** 短い（ボタンプレスなど） */
        readonly short: 150;
        /** 標準（トランジションなど） */
        readonly standard: 300;
        /** 長い（ページ遷移など） */
        readonly long: 500;
    };
    readonly easing: {
        /** 標準 */
        readonly standard: "ease-out";
        /** 加速 */
        readonly accelerate: "ease-in";
        /** 減速 */
        readonly decelerate: "ease-out";
        /** 弾む */
        readonly bounce: "cubic-bezier(0.68, -0.55, 0.265, 1.55)";
    };
    readonly image: {
        /** 最大サイズ（ピクセル） */
        readonly maxSize: 1024;
        /** 圧縮品質（0-1） */
        readonly quality: 0.7;
        /** サポートするフォーマット */
        readonly formats: readonly ["jpeg", "png", "webp"];
        /** サムネイルサイズ */
        readonly thumbnailSize: 200;
    };
    readonly notification: {
        /** デフォルト通知時間 */
        readonly defaultTime: "21:00";
        /** 通知時間の選択肢 */
        readonly timeOptions: readonly ["07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"];
    };
    readonly storageKeys: {
        /** 初回起動フラグ */
        readonly hasLaunchedBefore: "hasLaunchedBefore";
        /** オンボーディング完了フラグ */
        readonly hasCompletedOnboarding: "hasCompletedOnboarding";
        /** カラースキーム */
        readonly colorScheme: "colorScheme";
        /** 最終同期日時 */
        readonly lastSyncTime: "lastSyncTime";
    };
    readonly pricing: {
        /** 月額プレミアム */
        readonly monthlyPremium: 380;
        /** 年額プレミアム（35%割引） */
        readonly yearlyPremium: 2980;
        /** 通貨 */
        readonly currency: "JPY";
    };
};
export type Animation = typeof ANIMATION;
export type Easing = typeof EASING;
export type ImageConfig = typeof IMAGE;
export type NotificationConfig = typeof NOTIFICATION;
export type StorageKeys = typeof STORAGE_KEYS;
export type Pricing = typeof PRICING;
export type Config = typeof CONFIG;
//# sourceMappingURL=config.d.ts.map