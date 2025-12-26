/**
 * 課金関連の型定義
 * サブスクリプション、価格情報
 */
// ========================================
// ユーティリティ関数
// ========================================
/**
 * 年額プランの割引率を計算
 */
export function calculateYearlyDiscount(monthlyPrice, yearlyPrice) {
    const monthlyTotal = monthlyPrice * 12;
    if (monthlyTotal === 0)
        return 0;
    return Math.round((1 - yearlyPrice / monthlyTotal) * 100);
}
/**
 * 価格をフォーマット
 */
export function formatPrice(amount, currency = 'JPY', locale = 'ja-JP') {
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
export function isPurchaseActive(info) {
    if (!info.isActive)
        return false;
    if (!info.expiresAt)
        return true;
    return info.expiresAt > new Date();
}
//# sourceMappingURL=purchase.js.map