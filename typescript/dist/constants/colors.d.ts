/**
 * カラー定義
 * 両アプリで共通のセマンティックカラー
 */
/**
 * 状態を表すカラー
 */
export declare const SEMANTIC_COLORS: {
    /** 成功 */
    readonly success: "#4CAF50";
    /** 警告 */
    readonly warning: "#FF9800";
    /** エラー */
    readonly error: "#F44336";
    /** 情報 */
    readonly info: "#2196F3";
};
/**
 * バッジ（レアリティ）カラー
 */
export declare const BADGE_COLORS: {
    /** ブロンズ */
    readonly bronze: "#CD7F32";
    /** シルバー */
    readonly silver: "#C0C0C0";
    /** ゴールド */
    readonly gold: "#FFD700";
    /** プラチナ */
    readonly platinum: "#E5E4E2";
};
/**
 * かろやか（katazuke-app）のカラー
 */
export declare const KATAZUKE_COLORS: {
    /** プライマリ - グリーン */
    readonly primary: "#4CAF50";
    readonly primaryLight: "#81C784";
    readonly primaryDark: "#388E3C";
    /** セカンダリ - オレンジ */
    readonly secondary: "#FF9800";
    readonly secondaryLight: "#FFB74D";
    readonly secondaryDark: "#F57C00";
    /** アクセント - ピンク */
    readonly accent: "#E91E63";
    readonly accentLight: "#F48FB1";
};
/**
 * むすび（koukan-nikki-app）のカラー
 */
export declare const KOUKAN_COLORS: {
    /** プライマリ - ピンク */
    readonly primary: "#FFB6C1";
    readonly primaryDark: "#FF69B4";
    /** セカンダリ - パープル */
    readonly secondary: "#DDA0DD";
    readonly secondaryDark: "#BA55D3";
    /** アクセント - コーラル */
    readonly accent: "#FF7F7F";
    /** プレミアム - ゴールド */
    readonly premium: "#FFD700";
};
/**
 * ライトテーマ（共通）
 */
export declare const LIGHT_THEME: {
    readonly background: "#FFFFFF";
    readonly backgroundSecondary: "#F5F5F5";
    readonly backgroundTertiary: "#EEEEEE";
    readonly text: "#1A1A1A";
    readonly textSecondary: "#666666";
    readonly textTertiary: "#999999";
    readonly textInverse: "#FFFFFF";
    readonly border: "#E0E0E0";
    readonly borderLight: "#F0F0F0";
    readonly divider: "#EEEEEE";
    readonly card: "#FFFFFF";
    readonly cardShadow: "rgba(0, 0, 0, 0.08)";
    readonly overlay: "rgba(0, 0, 0, 0.5)";
    readonly skeleton: "#E0E0E0";
    readonly skeletonHighlight: "#F0F0F0";
};
/**
 * ダークテーマ（共通）
 */
export declare const DARK_THEME: {
    readonly background: "#1A1A1A";
    readonly backgroundSecondary: "#2A2A2A";
    readonly backgroundTertiary: "#3A3A3A";
    readonly text: "#FFFFFF";
    readonly textSecondary: "#AAAAAA";
    readonly textTertiary: "#777777";
    readonly textInverse: "#1A1A1A";
    readonly border: "#3A3A3A";
    readonly borderLight: "#2A2A2A";
    readonly divider: "#3A3A3A";
    readonly card: "#2A2A2A";
    readonly cardShadow: "rgba(0, 0, 0, 0.3)";
    readonly overlay: "rgba(0, 0, 0, 0.7)";
    readonly skeleton: "#2A2A2A";
    readonly skeletonHighlight: "#3A3A3A";
};
export declare const COLORS: {
    readonly semantic: {
        /** 成功 */
        readonly success: "#4CAF50";
        /** 警告 */
        readonly warning: "#FF9800";
        /** エラー */
        readonly error: "#F44336";
        /** 情報 */
        readonly info: "#2196F3";
    };
    readonly badge: {
        /** ブロンズ */
        readonly bronze: "#CD7F32";
        /** シルバー */
        readonly silver: "#C0C0C0";
        /** ゴールド */
        readonly gold: "#FFD700";
        /** プラチナ */
        readonly platinum: "#E5E4E2";
    };
    readonly katazuke: {
        /** プライマリ - グリーン */
        readonly primary: "#4CAF50";
        readonly primaryLight: "#81C784";
        readonly primaryDark: "#388E3C";
        /** セカンダリ - オレンジ */
        readonly secondary: "#FF9800";
        readonly secondaryLight: "#FFB74D";
        readonly secondaryDark: "#F57C00";
        /** アクセント - ピンク */
        readonly accent: "#E91E63";
        readonly accentLight: "#F48FB1";
    };
    readonly koukan: {
        /** プライマリ - ピンク */
        readonly primary: "#FFB6C1";
        readonly primaryDark: "#FF69B4";
        /** セカンダリ - パープル */
        readonly secondary: "#DDA0DD";
        readonly secondaryDark: "#BA55D3";
        /** アクセント - コーラル */
        readonly accent: "#FF7F7F";
        /** プレミアム - ゴールド */
        readonly premium: "#FFD700";
    };
    readonly light: {
        readonly background: "#FFFFFF";
        readonly backgroundSecondary: "#F5F5F5";
        readonly backgroundTertiary: "#EEEEEE";
        readonly text: "#1A1A1A";
        readonly textSecondary: "#666666";
        readonly textTertiary: "#999999";
        readonly textInverse: "#FFFFFF";
        readonly border: "#E0E0E0";
        readonly borderLight: "#F0F0F0";
        readonly divider: "#EEEEEE";
        readonly card: "#FFFFFF";
        readonly cardShadow: "rgba(0, 0, 0, 0.08)";
        readonly overlay: "rgba(0, 0, 0, 0.5)";
        readonly skeleton: "#E0E0E0";
        readonly skeletonHighlight: "#F0F0F0";
    };
    readonly dark: {
        readonly background: "#1A1A1A";
        readonly backgroundSecondary: "#2A2A2A";
        readonly backgroundTertiary: "#3A3A3A";
        readonly text: "#FFFFFF";
        readonly textSecondary: "#AAAAAA";
        readonly textTertiary: "#777777";
        readonly textInverse: "#1A1A1A";
        readonly border: "#3A3A3A";
        readonly borderLight: "#2A2A2A";
        readonly divider: "#3A3A3A";
        readonly card: "#2A2A2A";
        readonly cardShadow: "rgba(0, 0, 0, 0.3)";
        readonly overlay: "rgba(0, 0, 0, 0.7)";
        readonly skeleton: "#2A2A2A";
        readonly skeletonHighlight: "#3A3A3A";
    };
};
export type SemanticColors = typeof SEMANTIC_COLORS;
export type BadgeColors = typeof BADGE_COLORS;
export type LightTheme = typeof LIGHT_THEME;
export type DarkTheme = typeof DARK_THEME;
export type Theme = LightTheme | DarkTheme;
/**
 * テーマに応じたカラーを取得
 */
export declare function getThemeColors(isDark: boolean): Theme;
/**
 * HEX を RGB に変換
 */
export declare function hexToRgb(hex: string): {
    r: number;
    g: number;
    b: number;
} | null;
/**
 * HEX を RGBA に変換
 */
export declare function hexToRgba(hex: string, alpha: number): string;
//# sourceMappingURL=colors.d.ts.map