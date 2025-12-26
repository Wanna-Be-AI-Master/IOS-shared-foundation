/**
 * 認証関連の型定義
 * Apple Sign-In、セッション管理
 */

// ========================================
// 認証状態
// ========================================

/**
 * 認証状態
 */
export type AuthState =
  | 'loading'           // 認証状態確認中
  | 'unauthenticated'   // 未認証
  | 'authenticated'     // 認証済み
  | 'profileSetup';     // プロフィール設定中

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
export type AuthErrorCode =
  | 'AUTH_INVALID_CREDENTIAL'   // 認証情報が無効
  | 'AUTH_SESSION_EXPIRED'      // セッション期限切れ
  | 'AUTH_USER_NOT_FOUND'       // ユーザーが見つからない
  | 'AUTH_CANCELLED'            // ユーザーがキャンセル
  | 'AUTH_UNKNOWN';             // 不明なエラー

// ========================================
// ユーティリティ関数
// ========================================

/**
 * セッションが有効かどうかを判定
 */
export function isSessionValid(session: Session | null): boolean {
  if (!session) return false;
  return session.expiresAt > new Date();
}

/**
 * Apple認証情報からフルネームを取得
 */
export function getFullNameFromCredential(
  credential: AppleAuthCredential
): string | null {
  if (!credential.fullName) return null;
  const { givenName, familyName } = credential.fullName;
  if (!givenName && !familyName) return null;
  return [familyName, givenName].filter(Boolean).join(' ');
}
