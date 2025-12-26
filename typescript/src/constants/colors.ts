/**
 * カラー定義
 * 両アプリで共通のセマンティックカラー
 */

// ========================================
// セマンティックカラー（共通）
// ========================================

/**
 * 状態を表すカラー
 */
export const SEMANTIC_COLORS = {
  /** 成功 */
  success: '#4CAF50',
  /** 警告 */
  warning: '#FF9800',
  /** エラー */
  error: '#F44336',
  /** 情報 */
  info: '#2196F3',
} as const;

/**
 * バッジ（レアリティ）カラー
 */
export const BADGE_COLORS = {
  /** ブロンズ */
  bronze: '#CD7F32',
  /** シルバー */
  silver: '#C0C0C0',
  /** ゴールド */
  gold: '#FFD700',
  /** プラチナ */
  platinum: '#E5E4E2',
} as const;

// ========================================
// アプリ別ブランドカラー
// ========================================

/**
 * かろやか（katazuke-app）のカラー
 */
export const KATAZUKE_COLORS = {
  /** プライマリ - グリーン */
  primary: '#4CAF50',
  primaryLight: '#81C784',
  primaryDark: '#388E3C',
  /** セカンダリ - オレンジ */
  secondary: '#FF9800',
  secondaryLight: '#FFB74D',
  secondaryDark: '#F57C00',
  /** アクセント - ピンク */
  accent: '#E91E63',
  accentLight: '#F48FB1',
} as const;

/**
 * むすび（koukan-nikki-app）のカラー
 */
export const KOUKAN_COLORS = {
  /** プライマリ - ピンク */
  primary: '#FFB6C1',
  primaryDark: '#FF69B4',
  /** セカンダリ - パープル */
  secondary: '#DDA0DD',
  secondaryDark: '#BA55D3',
  /** アクセント - コーラル */
  accent: '#FF7F7F',
  /** プレミアム - ゴールド */
  premium: '#FFD700',
} as const;

// ========================================
// テーマカラー
// ========================================

/**
 * ライトテーマ（共通）
 */
export const LIGHT_THEME = {
  background: '#FFFFFF',
  backgroundSecondary: '#F5F5F5',
  backgroundTertiary: '#EEEEEE',
  text: '#1A1A1A',
  textSecondary: '#666666',
  textTertiary: '#999999',
  textInverse: '#FFFFFF',
  border: '#E0E0E0',
  borderLight: '#F0F0F0',
  divider: '#EEEEEE',
  card: '#FFFFFF',
  cardShadow: 'rgba(0, 0, 0, 0.08)',
  overlay: 'rgba(0, 0, 0, 0.5)',
  skeleton: '#E0E0E0',
  skeletonHighlight: '#F0F0F0',
} as const;

/**
 * ダークテーマ（共通）
 */
export const DARK_THEME = {
  background: '#1A1A1A',
  backgroundSecondary: '#2A2A2A',
  backgroundTertiary: '#3A3A3A',
  text: '#FFFFFF',
  textSecondary: '#AAAAAA',
  textTertiary: '#777777',
  textInverse: '#1A1A1A',
  border: '#3A3A3A',
  borderLight: '#2A2A2A',
  divider: '#3A3A3A',
  card: '#2A2A2A',
  cardShadow: 'rgba(0, 0, 0, 0.3)',
  overlay: 'rgba(0, 0, 0, 0.7)',
  skeleton: '#2A2A2A',
  skeletonHighlight: '#3A3A3A',
} as const;

// ========================================
// エクスポート
// ========================================

export const COLORS = {
  semantic: SEMANTIC_COLORS,
  badge: BADGE_COLORS,
  katazuke: KATAZUKE_COLORS,
  koukan: KOUKAN_COLORS,
  light: LIGHT_THEME,
  dark: DARK_THEME,
} as const;

// ========================================
// 型定義
// ========================================

export type SemanticColors = typeof SEMANTIC_COLORS;
export type BadgeColors = typeof BADGE_COLORS;
export type LightTheme = typeof LIGHT_THEME;
export type DarkTheme = typeof DARK_THEME;
export type Theme = LightTheme | DarkTheme;

// ========================================
// ユーティリティ関数
// ========================================

/**
 * テーマに応じたカラーを取得
 */
export function getThemeColors(isDark: boolean): Theme {
  return isDark ? DARK_THEME : LIGHT_THEME;
}

/**
 * HEX を RGB に変換
 */
export function hexToRgb(hex: string): { r: number; g: number; b: number } | null {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16),
      }
    : null;
}

/**
 * HEX を RGBA に変換
 */
export function hexToRgba(hex: string, alpha: number): string {
  const rgb = hexToRgb(hex);
  if (!rgb) return hex;
  return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${alpha})`;
}
