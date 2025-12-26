/**
 * 共通設定定義
 * タイムゾーン、アニメーション、画像設定など
 */
// ========================================
// タイムゾーン
// ========================================
/** 日本タイムゾーン */
export const TIMEZONE = 'Asia/Tokyo';
/** デフォルトロケール */
export const DEFAULT_LOCALE = 'ja-JP';
// ========================================
// アニメーション
// ========================================
/**
 * アニメーション時間（ミリ秒）
 */
export const ANIMATION = {
    /** 短い（ボタンプレスなど） */
    short: 150,
    /** 標準（トランジションなど） */
    standard: 300,
    /** 長い（ページ遷移など） */
    long: 500,
};
/**
 * イージング
 */
export const EASING = {
    /** 標準 */
    standard: 'ease-out',
    /** 加速 */
    accelerate: 'ease-in',
    /** 減速 */
    decelerate: 'ease-out',
    /** 弾む */
    bounce: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
};
// ========================================
// 画像
// ========================================
/**
 * 画像設定
 */
export const IMAGE = {
    /** 最大サイズ（ピクセル） */
    maxSize: 1024,
    /** 圧縮品質（0-1） */
    quality: 0.7,
    /** サポートするフォーマット */
    formats: ['jpeg', 'png', 'webp'],
    /** サムネイルサイズ */
    thumbnailSize: 200,
};
// ========================================
// 通知
// ========================================
/**
 * 通知設定
 */
export const NOTIFICATION = {
    /** デフォルト通知時間 */
    defaultTime: '21:00',
    /** 通知時間の選択肢 */
    timeOptions: [
        '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
        '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
        '19:00', '20:00', '21:00', '22:00', '23:00',
    ],
};
// ========================================
// ストレージキー
// ========================================
/**
 * ローカルストレージキー（共通）
 */
export const STORAGE_KEYS = {
    /** 初回起動フラグ */
    hasLaunchedBefore: 'hasLaunchedBefore',
    /** オンボーディング完了フラグ */
    hasCompletedOnboarding: 'hasCompletedOnboarding',
    /** カラースキーム */
    colorScheme: 'colorScheme',
    /** 最終同期日時 */
    lastSyncTime: 'lastSyncTime',
};
// ========================================
// 価格（日本円）
// ========================================
/**
 * 共通価格設定
 */
export const PRICING = {
    /** 月額プレミアム */
    monthlyPremium: 380,
    /** 年額プレミアム（35%割引） */
    yearlyPremium: 2980,
    /** 通貨 */
    currency: 'JPY',
};
// ========================================
// エクスポート
// ========================================
export const CONFIG = {
    timezone: TIMEZONE,
    locale: DEFAULT_LOCALE,
    animation: ANIMATION,
    easing: EASING,
    image: IMAGE,
    notification: NOTIFICATION,
    storageKeys: STORAGE_KEYS,
    pricing: PRICING,
};
//# sourceMappingURL=config.js.map