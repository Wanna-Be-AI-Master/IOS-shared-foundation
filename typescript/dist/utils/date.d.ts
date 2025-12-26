/**
 * 日付処理ユーティリティ
 * 日本語フォーマット、相対時間、タイムゾーン
 */
/** 日本タイムゾーン */
export declare const TIMEZONE = "Asia/Tokyo";
/** 日付フォーマットパターン */
export declare const DATE_FORMATS: {
    /** 2024年12月26日 (木) */
    readonly full: "yyyy年M月d日 (E)";
    /** 2024年12月26日 */
    readonly long: "yyyy年M月d日";
    /** 12月26日 */
    readonly medium: "M月d日";
    /** 12/26 */
    readonly short: "M/d";
    /** 12月26日 10:30 */
    readonly datetime: "M月d日 HH:mm";
    /** 10:30 */
    readonly time: "HH:mm";
    /** 2024-12-26 */
    readonly iso: "yyyy-MM-dd";
};
export type DateFormatStyle = keyof typeof DATE_FORMATS;
/**
 * 日付をフォーマット
 * @param date 日付
 * @param style フォーマットスタイル
 * @returns フォーマット済み文字列
 */
export declare function formatDate(date: Date | string | number, style?: DateFormatStyle): string;
/**
 * 相対時間をフォーマット（〜前）
 * @param date 日付
 * @returns 相対時間文字列
 */
export declare function formatRelativeTime(date: Date | string | number): string;
/**
 * 日時をフォーマット（相対時間 + 時刻）
 * @param date 日付
 * @returns フォーマット済み文字列
 */
export declare function formatDateTime(date: Date | string | number): string;
/**
 * 今日かどうかを判定
 */
export declare function isToday(date: Date | string | number): boolean;
/**
 * 昨日かどうかを判定
 */
export declare function isYesterday(date: Date | string | number): boolean;
/**
 * 日の開始時刻を取得
 */
export declare function startOfDay(date: Date | string | number): Date;
/**
 * 2つの日付の日数差を計算
 */
export declare function getDaysDifference(date1: Date | string | number, date2: Date | string | number): number;
/**
 * Date型に変換
 */
export declare function toDate(date: Date | string | number): Date;
/**
 * ISO文字列に変換
 */
export declare function toISOString(date: Date | string | number): string;
/**
 * タイムスタンプに変換
 */
export declare function toTimestamp(date: Date | string | number): number;
//# sourceMappingURL=date.d.ts.map