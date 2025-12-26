/**
 * 課金関連の型定義
 * サブスクリプション、価格情報
 */
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
/**
 * 年額プランの割引率を計算
 */
export declare function calculateYearlyDiscount(monthlyPrice: number, yearlyPrice: number): number;
/**
 * 価格をフォーマット
 */
export declare function formatPrice(amount: number, currency?: string, locale?: string): string;
/**
 * 購入がアクティブかどうかを判定
 */
export declare function isPurchaseActive(info: PurchaseInfo): boolean;
//# sourceMappingURL=purchase.d.ts.map