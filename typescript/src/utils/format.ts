/**
 * フォーマットユーティリティ
 * 数値、価格、パーセンテージ
 */

// ========================================
// 数値フォーマット
// ========================================

/**
 * 数値をフォーマット（カンマ区切り）
 * @example formatNumber(1234567) // "1,234,567"
 */
export function formatNumber(
  num: number,
  locale = 'ja-JP'
): string {
  return new Intl.NumberFormat(locale).format(num);
}

/**
 * 価格をフォーマット
 * @example formatPrice(380) // "¥380"
 */
export function formatCurrency(
  amount: number,
  currency = 'JPY',
  locale = 'ja-JP'
): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
}

/**
 * パーセンテージをフォーマット
 * @example formatPercentage(0.35) // "35%"
 */
export function formatPercentage(
  value: number,
  decimals = 0
): string {
  return `${(value * 100).toFixed(decimals)}%`;
}

/**
 * ファイルサイズをフォーマット
 * @example formatFileSize(1234567) // "1.18 MB"
 */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 B';

  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  const k = 1024;
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${units[i]}`;
}

// ========================================
// 文字列フォーマット
// ========================================

/**
 * 文字列を指定長で切り詰め
 * @example truncate("長いテキスト", 5) // "長いテ..."
 */
export function truncate(
  str: string,
  maxLength: number,
  suffix = '...'
): string {
  if (str.length <= maxLength) return str;
  return str.slice(0, maxLength - suffix.length) + suffix;
}

/**
 * 文字列の先頭を大文字に
 */
export function capitalize(str: string): string {
  if (!str) return str;
  return str.charAt(0).toUpperCase() + str.slice(1);
}

/**
 * snake_case を camelCase に変換
 */
export function snakeToCamel(str: string): string {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
}

/**
 * camelCase を snake_case に変換
 */
export function camelToSnake(str: string): string {
  return str.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`);
}

// ========================================
// 配列/オブジェクトフォーマット
// ========================================

/**
 * 配列を日本語の列挙形式に
 * @example formatList(["A", "B", "C"]) // "A、B、C"
 */
export function formatList(
  items: string[],
  separator = '、',
  lastSeparator = '、'
): string {
  if (items.length === 0) return '';
  if (items.length === 1) return items[0];
  if (items.length === 2) return items.join(lastSeparator);

  const allButLast = items.slice(0, -1);
  const last = items[items.length - 1];
  return allButLast.join(separator) + lastSeparator + last;
}

/**
 * カウント表示
 * @example formatCount(5, "件") // "5件"
 */
export function formatCount(
  count: number,
  unit: string
): string {
  return `${formatNumber(count)}${unit}`;
}

/**
 * 範囲表示
 * @example formatRange(1, 10) // "1〜10"
 */
export function formatRange(
  start: number,
  end: number,
  separator = '〜'
): string {
  return `${formatNumber(start)}${separator}${formatNumber(end)}`;
}
