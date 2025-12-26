/**
 * フォーマットユーティリティ
 * 数値、価格、パーセンテージ
 */
/**
 * 数値をフォーマット（カンマ区切り）
 * @example formatNumber(1234567) // "1,234,567"
 */
export declare function formatNumber(num: number, locale?: string): string;
/**
 * 価格をフォーマット
 * @example formatPrice(380) // "¥380"
 */
export declare function formatCurrency(amount: number, currency?: string, locale?: string): string;
/**
 * パーセンテージをフォーマット
 * @example formatPercentage(0.35) // "35%"
 */
export declare function formatPercentage(value: number, decimals?: number): string;
/**
 * ファイルサイズをフォーマット
 * @example formatFileSize(1234567) // "1.18 MB"
 */
export declare function formatFileSize(bytes: number): string;
/**
 * 文字列を指定長で切り詰め
 * @example truncate("長いテキスト", 5) // "長いテ..."
 */
export declare function truncate(str: string, maxLength: number, suffix?: string): string;
/**
 * 文字列の先頭を大文字に
 */
export declare function capitalize(str: string): string;
/**
 * snake_case を camelCase に変換
 */
export declare function snakeToCamel(str: string): string;
/**
 * camelCase を snake_case に変換
 */
export declare function camelToSnake(str: string): string;
/**
 * 配列を日本語の列挙形式に
 * @example formatList(["A", "B", "C"]) // "A、B、C"
 */
export declare function formatList(items: string[], separator?: string, lastSeparator?: string): string;
/**
 * カウント表示
 * @example formatCount(5, "件") // "5件"
 */
export declare function formatCount(count: number, unit: string): string;
/**
 * 範囲表示
 * @example formatRange(1, 10) // "1〜10"
 */
export declare function formatRange(start: number, end: number, separator?: string): string;
//# sourceMappingURL=format.d.ts.map