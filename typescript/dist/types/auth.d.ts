/**
 * 認証関連の型定義
 * Apple Sign-In、セッション管理
 */
/**
 * 認証状態
 */
export type AuthState = 'loading' | 'unauthenticated' | 'authenticated' | 'profileSetup';
/**
 * Apple Sign-In認証情報
 */
export interface AppleAuthCredential {
    /** Identity Token（JWTトークン） */
    identityToken: string;
    /** Authorization Code */
    authorizationCode: string;
    /** Apple User ID */
    user: string;
    /** メールアドレス（初回認証時のみ） */
    email: string | null;
    /** フルネーム（初回認証時のみ） */
    fullName: {
        givenName: string | null;
        familyName: string | null;
    } | null;
}
/**
 * セッション情報
 */
export interface Session {
    /** アクセストークン */
    accessToken: string;
    /** リフレッシュトークン */
    refreshToken: string;
    /** トークン有効期限 */
    expiresAt: Date;
    /** ユーザー情報 */
    user: {
        id: string;
        email?: string;
    };
}
/**
 * 認証エラーコード
 */
export type AuthErrorCode = 'AUTH_INVALID_CREDENTIAL' | 'AUTH_SESSION_EXPIRED' | 'AUTH_USER_NOT_FOUND' | 'AUTH_CANCELLED' | 'AUTH_UNKNOWN';
/**
 * セッションが有効かどうかを判定
 */
export declare function isSessionValid(session: Session | null): boolean;
/**
 * Apple認証情報からフルネームを取得
 */
export declare function getFullNameFromCredential(credential: AppleAuthCredential): string | null;
//# sourceMappingURL=auth.d.ts.map