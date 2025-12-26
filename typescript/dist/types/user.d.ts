/**
 * ユーザー関連の型定義
 * 両アプリで共通して使用するユーザー基本情報
 */
/**
 * ユーザーの基本情報
 * 両アプリで共通のフィールド
 */
export interface BaseUser {
    /** ユーザーID（UUID） */
    id: string;
    /** Apple ID（Sign in with Apple用） */
    appleId: string | null;
    /** メールアドレス */
    email: string | null;
    /** 表示名 */
    displayName: string;
    /** プロフィール画像URL */
    profileImageUrl: string | null;
}
/**
 * プレミアム情報
 */
export interface PremiumInfo {
    /** プレミアム会員かどうか */
    isPremium: boolean;
    /** プレミアム有効期限 */
    premiumExpiresAt: Date | null;
}
/**
 * タイムスタンプ
 */
export interface Timestamps {
    /** 作成日時 */
    createdAt: Date;
    /** 更新日時 */
    updatedAt: Date;
}
/**
 * 外観モード
 */
export type AppearanceMode = 'system' | 'light' | 'dark';
/**
 * 基本ユーザー設定
 * 両アプリで共通の設定項目
 */
export interface BaseUserSettings {
    /** 通知が有効かどうか */
    notificationEnabled: boolean;
    /** 通知時間（HH:mm形式） */
    notificationTime: string;
    /** 外観モード */
    appearanceMode: AppearanceMode;
}
/**
 * ユーザー作成入力
 */
export interface UserCreateInput {
    /** Apple ID */
    appleId: string;
    /** メールアドレス */
    email: string | null;
    /** 表示名 */
    displayName: string;
}
/**
 * ユーザー更新入力
 */
export interface UserUpdateInput {
    /** 表示名 */
    displayName?: string;
    /** プロフィール画像URL */
    profileImageUrl?: string | null;
}
/**
 * プレミアムが有効かどうかを判定
 */
export declare function isPremiumActive(info: PremiumInfo): boolean;
/**
 * 表示名またはデフォルト名を取得
 */
export declare function getDisplayNameOrDefault(displayName: string | null | undefined, defaultName?: string): string;
//# sourceMappingURL=user.d.ts.map