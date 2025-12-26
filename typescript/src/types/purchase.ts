/**
 * 課金関連の型定義
 * サブスクリプション、価格情報
 */

// ========================================
// サブスクリプション
// ========================================

/**
 * サブスクリプションプラン
 */
export type SubscriptionPlan = 'free' | 'premium';

/**
 * 購入情報
 */
export interface PurchaseInfo {
  /** プラン */
  plan: SubscriptionPlan;
  /** アクティブかどうか */
  isActive: boolean;
  /** 有効期限 */
  expiresAt: Date | null;
  /** 自動更新するか */
  willRenew: boolean;
}

/**
 * 価格情報
 */
export interface PricingInfo {
  /** 月額価格 */
  monthlyPrice: number;
  /** 年額価格 */
  yearlyPrice: number;
  /** 通貨 */
  currency: string;
}

/**
 * 製品ID
 */
export interface ProductIds {
  /** 月額プラン */
  monthlyPremium: string;
  /** 年額プラン */
  yearlyPremium: string;
}

// ========================================
// ユーティリティ関数
// ========================================

/**
 * 年額プランの割引率を計算
 */
export function calculateYearlyDiscount(
  monthlyPrice: number,
  yearlyPrice: number
): number {
  const monthlyTotal = monthlyPrice * 12;
  if (monthlyTotal === 0) return 0;
  return Math.round((1 - yearlyPrice / monthlyTotal) * 100);
}

/**
 * 価格をフォーマット
 */
export function formatPrice(
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
 * 購入がアクティブかどうかを判定
 */
export function isPurchaseActive(info: PurchaseInfo): boolean {
  if (!info.isActive) return false;
  if (!info.expiresAt) return true;
  return info.expiresAt > new Date();
}
