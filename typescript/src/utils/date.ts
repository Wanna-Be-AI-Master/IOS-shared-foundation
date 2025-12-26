/**
 * 日付処理ユーティリティ
 * 日本語フォーマット、相対時間、タイムゾーン
 */

import {
  format,
  isToday as fnsIsToday,
  isYesterday as fnsIsYesterday,
  startOfDay as fnsStartOfDay,
  differenceInDays,
  differenceInMinutes,
  differenceInHours,
} from 'date-fns';
import { ja } from 'date-fns/locale';

// ========================================
// 定数
// ========================================

/** 日本タイムゾーン */
export const TIMEZONE = 'Asia/Tokyo';

/** 日付フォーマットパターン */
export const DATE_FORMATS = {
  /** 2024年12月26日 (木) */
  full: 'yyyy年M月d日 (E)',
  /** 2024年12月26日 */
  long: 'yyyy年M月d日',
  /** 12月26日 */
  medium: 'M月d日',
  /** 12/26 */
  short: 'M/d',
  /** 12月26日 10:30 */
  datetime: 'M月d日 HH:mm',
  /** 10:30 */
  time: 'HH:mm',
  /** 2024-12-26 */
  iso: 'yyyy-MM-dd',
} as const;

export type DateFormatStyle = keyof typeof DATE_FORMATS;

// ========================================
// フォーマット関数
// ========================================

/**
 * 日付をフォーマット
 * @param date 日付
 * @param style フォーマットスタイル
 * @returns フォーマット済み文字列
 */
export function formatDate(
  date: Date | string | number,
  style: DateFormatStyle = 'medium'
): string {
  const d = toDate(date);
  return format(d, DATE_FORMATS[style], { locale: ja });
}

/**
 * 相対時間をフォーマット（〜前）
 * @param date 日付
 * @returns 相対時間文字列
 */
export function formatRelativeTime(date: Date | string | number): string {
  const d = toDate(date);
  const now = new Date();
  const minutes = differenceInMinutes(now, d);
  const hours = differenceInHours(now, d);
  const days = differenceInDays(now, d);

  // 1分未満
  if (minutes < 1) {
    return 'たった今';
  }

  // 1時間未満
  if (minutes < 60) {
    return `${minutes}分前`;
  }

  // 24時間未満
  if (hours < 24) {
    return `${hours}時間前`;
  }

  // 昨日
  if (fnsIsYesterday(d)) {
    return '昨日';
  }

  // 7日以内
  if (days <= 7) {
    return `${days}日前`;
  }

  // それ以外は日付表示
  return formatDate(d, 'medium');
}

/**
 * 日時をフォーマット（相対時間 + 時刻）
 * @param date 日付
 * @returns フォーマット済み文字列
 */
export function formatDateTime(date: Date | string | number): string {
  const d = toDate(date);

  if (fnsIsToday(d)) {
    return `今日 ${format(d, 'HH:mm', { locale: ja })}`;
  }

  if (fnsIsYesterday(d)) {
    return `昨日 ${format(d, 'HH:mm', { locale: ja })}`;
  }

  return formatDate(d, 'datetime');
}

// ========================================
// 判定関数
// ========================================

/**
 * 今日かどうかを判定
 */
export function isToday(date: Date | string | number): boolean {
  return fnsIsToday(toDate(date));
}

/**
 * 昨日かどうかを判定
 */
export function isYesterday(date: Date | string | number): boolean {
  return fnsIsYesterday(toDate(date));
}

/**
 * 日の開始時刻を取得
 */
export function startOfDay(date: Date | string | number): Date {
  return fnsStartOfDay(toDate(date));
}

/**
 * 2つの日付の日数差を計算
 */
export function getDaysDifference(
  date1: Date | string | number,
  date2: Date | string | number
): number {
  return differenceInDays(toDate(date1), toDate(date2));
}

// ========================================
// 変換関数
// ========================================

/**
 * Date型に変換
 */
export function toDate(date: Date | string | number): Date {
  if (date instanceof Date) return date;
  return new Date(date);
}

/**
 * ISO文字列に変換
 */
export function toISOString(date: Date | string | number): string {
  return toDate(date).toISOString();
}

/**
 * タイムスタンプに変換
 */
export function toTimestamp(date: Date | string | number): number {
  return toDate(date).getTime();
}
